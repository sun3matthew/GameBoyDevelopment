import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.lang.Byte;
import java.io.FileOutputStream;

public class PngToBin {
    public static int[][][] readImage(String name){
        BufferedImage picture;
        int[][][] pixelArray;
        try{
            picture = ImageIO.read(new File(name));
        }catch (Exception e)
        {
            System.out.println("There was a error reading the picture\n" + e);
            return null;
        }

        pixelArray = new int[picture.getHeight()][picture.getWidth()][4];
        for (int row = 0; row < pixelArray.length; row++)
        {
          for (int col = 0; col < pixelArray[0].length; col++)
          {
            int value = picture.getRGB(col, row);
            int alpha = (value >> 24) & 0xff;
            int red = (value >> 16) & 0xff;
            int green = (value >>  8) & 0xff;
            int blue = value & 0xff;
            pixelArray[row][col][0] = red;
            pixelArray[row][col][1] = green;
            pixelArray[row][col][2] = blue;
            pixelArray[row][col][3] = alpha;
          }
        }
        return pixelArray;
    }
    public static void writeBinaryFile(ArrayList<Byte> data, String name){
        try{
            File file = new File(name);
            file.createNewFile();
            byte[] bytes = new byte[data.size()];
            for(int i = 0; i < data.size(); i++)
                bytes[i] = data.get(i);
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(bytes);
            fos.close();
        }catch(IOException e){
            System.out.println("An error occurred.");
        }
    }

    public static int getColor(int[][] colors, int startIdx, int[] color){
        for(int i = startIdx; i < colors.length; i++)
            if(colors[i][0] == color[0] && colors[i][1] == color[1] && colors[i][2] == color[2])
                return i;
        return -1;
    }

    public static void main(String[] args) {
        int[][][] pixelArray = readImage(args[0]);
        ArrayList<Byte> data = new ArrayList<Byte>();
        // 2bpp

        //check divide by 8
        if(pixelArray.length % 8 != 0 || pixelArray[0].length % 8 != 0){
            System.out.println("Error: image dimensions must be divisible by 8");
            return;
        }

        boolean isObject = false;
        int[][] colors = new int[4][3];
        for(int i = 0; i < colors.length; i++)
            for(int j = 0; j < colors[0].length; j++)
                colors[i][j] = -1;

        int firstColor = 0;
        for(int row = 0; row < pixelArray.length && !isObject; row++)
            for(int col = 0; col < pixelArray[0].length && !isObject; col++)
                if(pixelArray[row][col][3] == 0)
                    isObject = true;
        
        if(isObject)
            firstColor = 1;

        int[][] palletImage = new int[pixelArray.length][pixelArray[0].length];
        int colorIndex = firstColor;
        for(int row = 0; row < pixelArray.length; row++){
            for(int col = 0; col < pixelArray[0].length; col++){
                int color = getColor(colors, firstColor, pixelArray[row][col]);
                if(color == -1){
                    colors[colorIndex][0] = pixelArray[row][col][0];
                    colors[colorIndex][1] = pixelArray[row][col][1];
                    colors[colorIndex][2] = pixelArray[row][col][2];
                    palletImage[row][col] = colorIndex;
                    colorIndex++;
                    if(colorIndex > 4){
                        System.out.println("Error: more than 4 colors");
                        return;
                    }
                }else{
                    palletImage[row][col] = color;
                }
            }
        }

        //debug: print pallet image
        /*
        for(int row = 0; row < palletImage.length; row++){
            for(int col = 0; col < palletImage[0].length; col++){
                System.out.print(palletImage[row][col]);
            }
            System.out.println();
        }
        */

        //debug: print original image
        /*
        for(int row = 0; row < pixelArray.length; row++){
            for(int col = 0; col < pixelArray[0].length; col++){
                System.out.print(pixelArray[row][col][0] + " " + pixelArray[row][col][1] + " " + pixelArray[row][col][2] + " | ");
            }
            System.out.println();
        }
        */

        //each tile is 8x8
        ArrayList<Byte> tbpp = new ArrayList<Byte>();
        int numTiles = (pixelArray.length / 8) * (pixelArray[0].length / 8);
        for(int tileY = 0; tileY < pixelArray.length; tileY += 8){
            for(int tileX = 0; tileX < pixelArray[0].length; tileX += 8){
                //System.out.println("Tile: " + tileX + " " + tileY);
                //each tile is 8x8

                // 0 2 3 3 3 3 2 0

                // 0 0 1 1 1 1 0 0
                // 0 1 1 1 1 1 1 0

                // 0x3c 0x7e
                for(int tileRow = tileY; tileRow < tileY + 8; tileRow++){
                    byte tileByte1 = 0;
                    byte tileByte2 = 0;
                    for(int tileCol = tileX; tileCol < tileX + 8; tileCol++){
                        byte color = (byte)(palletImage[tileRow][tileCol] & 0xff);
                        byte lower = (byte)((color >> 1) & 0x01);
                        byte upper = (byte)(color & 0x01);
                        tileByte1 = (byte)((tileByte1 << 1) | upper);
                        tileByte2 = (byte)((tileByte2 << 1) | lower);
                    }
                    tbpp.add(tileByte1);
                    tbpp.add(tileByte2);
                }
            }
        }

        writeBinaryFile(tbpp, args[1]);

        // 15-bit color little endian
        // 0-4 red, 5-9 green, 10-14 blue
        ArrayList<Byte> colorPallet = new ArrayList<Byte>();
        for(int i = 0; i < colors.length; i++){
            int red = colors[i][0] >> 3;
            int green = colors[i][1] >> 3;
            int blue = colors[i][2] >> 3;
            int color = (blue << 11) | (green << 6) | (red << 1);
            colorPallet.add((byte)(color & 0xff));
            colorPallet.add((byte)((color >> 8) & 0xff));
        }

        writeBinaryFile(colorPallet, args[2]);







        //writeBinaryFile(data, "output.p2b");        
        //export a pallet, 2bpp
    }    
}
