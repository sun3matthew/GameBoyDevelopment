import java.io.File;  // Import the File class
import java.io.IOException;  // Import the IOException class to handle errors
import java.io.FileWriter;   // Import the FileWriter class
import java.util.Scanner;
import java.util.ArrayList;

public class RegenMakeFile {
    public static void listOfFiles(ArrayList<String> paths, File dirPath){
        File filesList[] = dirPath.listFiles();
        for(File file : filesList) {
           if(file.isFile()) {
                paths.add(file.getPath());
           } else {
                listOfFiles(paths, file);
           }
        }
     }
    public static void main(String[] args) {
        try{
            File makeFile = new File("Makefile");
            Scanner reader = new Scanner(makeFile);
            String data = "";
            while (reader.hasNextLine())
                data += reader.nextLine() + "\n";
            reader.close();

            String[] lines = data.split("\n");
            ArrayList<String> newLines = new ArrayList<String>();


            int endIdx = 0;
            for(int i = 0; i < lines.length; i++)
                if(lines[i].contains("#AUTO-GENERATED"))
                    endIdx = i; 
            
            for(int i = 0; i <= endIdx; i++)
                newLines.add(lines[i]);
            
            /*
                #AUTO-GENERATED

                ../build/$(MAIN).gb: ../tmp/$(MAIN).o ../tmp/utils.o ../tmp/graphics.o
                    rgblink -n ../build/$(MAIN).sym -m ../log/$(MAIN).map -o ../build/$(MAIN).gb \
                        ../tmp/$(MAIN).o \
                        ../tmp/utils.o \
                        ../tmp/graphics.o
                    rgbfix $(RGBFIXFLAGS) ../build/$(MAIN).gb

                ../tmp/$(MAIN).o: src/$(MAIN).asm
                    rgbasm $(RGBASMFLAGS) -o ../tmp/$(MAIN).o src/$(MAIN).asm

                ../tmp/utils.o: lib/utils.asm
                    rgbasm $(RGBASMFLAGS) -o ../tmp/utils.o lib/utils.asm

                ../tmp/graphics.o: src/graphics.asm
                    rgbasm $(RGBASMFLAGS) -o ../tmp/graphics.o src/graphics.asm
            */

            ArrayList<String> paths = new ArrayList<String>();

            listOfFiles(paths, new File(args[0]));
            for(int i = 0; i < paths.size(); i++)
                paths.set(i, paths.get(i).replace(args[0] + "/", ""));

            ArrayList<String> asmFiles = new ArrayList<String>();
            ArrayList<String> objFiles = new ArrayList<String>();

            ArrayList<String> incFiles = new ArrayList<String>();

            ArrayList<String> pngFiles = new ArrayList<String>();
            ArrayList<String> tbppFiles = new ArrayList<String>();//2bpp
            ArrayList<String> palFiles = new ArrayList<String>();//2bpp
            for(int i = 0; i < paths.size(); i++){
                if(paths.get(i).contains(".asm")){
                    asmFiles.add(paths.get(i));
                    String objFile = paths.get(i).replace(".asm", ".o");
                    objFile = objFile.substring(objFile.lastIndexOf("/") + 1);
                    objFiles.add(objFile);
                }else if(paths.get(i).contains(".inc")){
                    incFiles.add(paths.get(i));
                }else if(paths.get(i).contains(".png")){
                    pngFiles.add(paths.get(i));
                    String tbppFile = paths.get(i).replace(".png", ".2bpp");
                    tbppFile = tbppFile.replace("raw", "bin");
                    tbppFiles.add(tbppFile);
                    String palFile = tbppFile.replace(".2bpp", ".pal");
                    palFiles.add(palFile);
                }
            }

            String lineBuffer = "";
            newLines.add("");

            lineBuffer = "../build/$(MAIN).gb: ";
            /*
            for(int i = 0; i < incFiles.size(); i++)
                lineBuffer += incFiles.get(i) + " ";
            for(int i = 0; i < tbppFiles.size(); i++)
                lineBuffer += tbppFiles.get(i) + " ";
            for(int i = 0; i < palFiles.size(); i++)
                lineBuffer += palFiles.get(i) + " ";
            */
            for(int i = 0; i < objFiles.size(); i++)
                lineBuffer += "../tmp/" + objFiles.get(i) + " ";

            newLines.add(lineBuffer);

            lineBuffer = "\trgblink -n ../build/$(MAIN).sym -M -m ../log/$(MAIN).map -o ../build/$(MAIN).gb \\";
            newLines.add(lineBuffer);

            for(int i = 0; i < objFiles.size(); i++){
                lineBuffer = "\t\t../tmp/" + objFiles.get(i) + " \\";
                if(i == objFiles.size() - 1)
                    lineBuffer = lineBuffer.substring(0, lineBuffer.length() - 2);
                newLines.add(lineBuffer);
            }

            lineBuffer = "\trgbfix $(RGBFIXFLAGS) ../build/$(MAIN).gb";
            newLines.add(lineBuffer);

            newLines.add("");

            for(int i = 0; i < asmFiles.size(); i++){
                lineBuffer = "../tmp/" + objFiles.get(i) + ": " + asmFiles.get(i);

                File asmFile = new File(asmFiles.get(i));
                String asmData = "";
                Scanner asmReader = new Scanner(asmFile);

                boolean done = false;
                boolean scanFullFile = false;
                while(asmReader.hasNextLine() && !done){
                    String line = asmReader.nextLine();
                    done = true;
                    if(line.contains("SCAN_FULL_FILE"))
                        scanFullFile = true;
                    if(line.length() == 0 || line.contains("INCLUDE") || line.contains("INCBIN")){
                        asmData += line + "\n";
                        done = false;
                    }
                    if(scanFullFile)
                        done = false;
                }
                asmReader.close();

                for(int j = 0; j < incFiles.size(); j++)
                    if(asmData.contains("INCLUDE \"" + incFiles.get(j) + "\""))
                        lineBuffer += " " + incFiles.get(j);
                for(int j = 0; j < tbppFiles.size(); j++)
                    if(asmData.contains("INCBIN \"" + tbppFiles.get(j) + "\""))
                        lineBuffer += " " + tbppFiles.get(j);
                for(int j = 0; j < palFiles.size(); j++)
                    if(asmData.contains("INCBIN \"" + palFiles.get(j) + "\""))
                        lineBuffer += " " + palFiles.get(j);



                newLines.add(lineBuffer);
                lineBuffer = "\trgbasm $(RGBASMFLAGS) -o ../tmp/" + objFiles.get(i) + " " + asmFiles.get(i);
                newLines.add(lineBuffer);
                newLines.add("");
            }

            newLines.add("");

            for(int i = 0; i < pngFiles.size(); i++){
                lineBuffer = tbppFiles.get(i) + " " + palFiles.get(i) + ": " + pngFiles.get(i);
                newLines.add(lineBuffer);
                lineBuffer = "\t" + "java -cp ../tools/graphics PngToBin " + pngFiles.get(i) + " " + tbppFiles.get(i) + " " + palFiles.get(i);
                newLines.add(lineBuffer);
                newLines.add("");
            }

            data = "";
            for(int i = 0; i < newLines.size(); i++)
                data += newLines.get(i) + "\n";

            FileWriter writer = new FileWriter("Makefile");
            writer.write(data);
            writer.close();
        }catch(IOException e){
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
    }
}