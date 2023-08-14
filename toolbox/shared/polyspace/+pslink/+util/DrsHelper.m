classdef DrsHelper




    methods(Static=true)




        function createDrsFile(fileName)
            import matlab.io.xml.dom.*

            [fpath,fname,fext]=fileparts(fileName);
            if isempty(fpath)
                fpath=pwd;
            end
            fileName=fullfile(fpath,[fname,fext]);

            xmlDoc=Document('global');
            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.FormatPrettyPrint=true;
            writeToURI(writer,xmlDoc,fileName);
        end




        function xmlDoc=readDrsFile(fileName)
            import matlab.io.xml.dom.*

            try

                xmlParser=Parser;
                xmlParser.Configuration.Namespaces=false;
                xmlDoc=parseFile(xmlParser,fileName);
            catch Me
                msg=message('polyspace:gui:pslink:failOpenDrs',fileName,Me.message).getString();
                newMe=MException('pslink:failOpenDrs',msg);
                throwAsCaller(newMe);
            end

            drsList=xmlDoc.getElementsByTagName('global');
            if drsList.getLength()~=1
                msg=message('polyspace:gui:pslink:invalidDrsFormat',fileName).getString();
                newMe=MException('pslink:invalidDrsFormat',msg);
                throwAsCaller(newMe);
            end
        end




        function writeDrsFile(fileName)
            if~isempty(fileName)

                dstName=tempname;
                fidSrc=fopen(fileName,'rt','native','UTF-8');
                fidDst=fopen(dstName,'w','native','UTF-8');
                lineNumber=1;
                while 1
                    tline=fgetl(fidSrc);
                    if~ischar(tline)
                        break
                    end
                    if lineNumber==2
                        fprintf(fidDst,'%s\n','<!--EDRS Version 2.0-->');
                    end
                    if~all(isspace(tline))
                        fprintf(fidDst,'%s\n',tline);
                    end
                    lineNumber=lineNumber+1;
                end
                fclose(fidSrc);
                fclose(fidDst);
                copyfile(dstName,fileName,'f');
            end
        end
    end
end
