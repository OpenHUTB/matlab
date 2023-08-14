classdef coderTargetDataIncludeWriter<handle










    properties
        Buffer=[]
    end

    methods
        function obj=coderTargetDataIncludeWriter()


            obj.Buffer=[];
        end

        function writeLine(obj,str)
            obj.Buffer{end+1}=[str,newline];
        end

        function bufferContent=returnContent(obj)
            bufferContent=sprintf('%s',obj.Buffer{:});
        end

        function writeDefines(obj,data,map,prefix)
            fields=fieldnames(data);
            for i=1:numel(fields)
                curfield=fields{i};
                name=[prefix,'_',upper(curfield)];
                if strcmp(curfield,'Scheduler_interrupt_source')
                    value=int16(data.(curfield));
                else
                    value=data.(curfield);
                end
                if isstruct(value)
                    if isfield(map,curfield)
                        map1=map.(curfield);
                    else
                        map1=[];
                    end
                    obj.writeDefines(value,map1,name);
                else
                    if(~isempty(map)&&isfield(map,curfield))
                        if~isempty(map.(curfield))
                            if ischar(value)
                                [~,value]=ismember(value,map.(curfield));
                                value=int16(value)-1;
                            else
                                value=value-1;
                            end
                        else
                            value=int16(value);
                        end
                    end
                    switch class(value)
                    case 'char'
                        obj.writeLine(['#define ','MW',name,' ',strrep(value,'\','/')]);
                    case{'single','double'}
                        obj.writeLine(['#define ','MW',name,' ',num2str(value,'%f')]);
                    otherwise
                        obj.writeLine(['#define ','MW',name,' ',num2str(value,'%d')]);
                    end
                end
            end
        end

        function writeCoderTargetIncludes(obj,str)
            obj.writeLine(['#include "',str,'"']);
        end

    end
end