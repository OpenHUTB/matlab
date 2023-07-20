



classdef Text<handle




    properties
text
    end


    methods
        function obj=Text(text)
            if text(end)~=newline
                obj.text=char(string(text)+newline);
            else
                obj.text=char(string(text));
            end
        end


        function trimLeadingLines(obj,count)
            crs=strfind(obj.text,newline);
            sz=size(crs,2);
            if count>sz
                error("The text only has %u lines.",sz);
            else
                pos=crs(count);
                obj.text=obj.text(pos+1:end);
            end
        end

        function concatToLine(obj,suffix,line,noError)
            if nargin<4
                noError=false;
            end
            crs=strfind(obj.text,newline);
            sz=size(crs,2);
            if line>sz
                if~noError
                    error("The text only has %u lines.",sz);
                end
            else
                pos=crs(line);
                before=obj.text(1:pos-1);
                added=char(suffix);
                after=obj.text(pos:end);
                obj.text=horzcat(before,added,after);
            end

        end


        function strings=toStrings(obj)
            strings=string(strsplit(obj.text,'\n'));
        end









        function padRHS(obj,amount)
            persistent formatter

            if isempty(formatter)
                formatter=nnet.internal.cnn.util.MixedWidthCharacterStringFormatter();
            end

            if nargin<2
                amount=0;
            end

            padded=formatter.rightPadToConsistentWidth(obj.toStrings());
            if amount>0
                added=string(repelem(' ',amount));
                padded=strcat(padded,added);
            end
            padded=strjoin(padded,'\n');
            obj.text=char(padded);



        end

        function sz=lineCount(obj)
            crs=strfind(obj.text,newline);
            sz=size(crs,2);
        end

        function width=getWidth(obj,line)
            crs=strfind(obj.text,newline);
            sz=size(crs,2);
            if line>sz
                error("The text only has %u lines.",sz);
            else
                if line==1
                    width=crs(line)-1;
                else
                    width=crs(line)-crs(line-1)-1;
                end
            end

        end
    end

    methods
        function disp(obj)
            obj.display();
        end
        function display(obj)
            fprintf("Text:\n")
            disp(strcat(obj.text));
        end
    end


end
