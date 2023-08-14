classdef(Sealed)FigFile<handle












    properties







        Path string="";









        FigFormat double=2;














        MatVersion char='';








        RequiredMatlabVersion double=-1;



        SaveObjects=false;
    end

    properties(Dependent,SetAccess=private)





RequiredMatlabVersionString


    end

    properties








        Format2Data struct=localDefaultV2Struct();






        Format3Data=[];
    end


    methods
        function obj=FigFile(file)







            if nargin
                obj.read(file);
            end
        end

        function set.FigFormat(obj,ver)

            if~isscalar(ver)||~any(ver==[-1,2,3])
                error(message('MATLAB:graphics:internal:figfile:FigFile:InvalidFigFormat'));
            end

            obj.FigFormat=ver;
        end

        function set.MatVersion(obj,verstr)

            if~any(strcmp(verstr,{'','-v6','-v7','-v7.3'}))
                error(message('MATLAB:graphics:internal:figfile:FigFile:InvalidMatVersion'));
            end

            obj.MatVersion=verstr;
        end

        function set.RequiredMatlabVersion(obj,ver)

            if~isscalar(ver)||fix(ver)~=ver||(ver~=-1&&ver<10000)
                error(message('MATLAB:graphics:internal:figfile:FigFile:InvalidRequiredMatlabVersion'));
            end

            obj.RequiredMatlabVersion=ver;
        end

        function set.Format2Data(obj,data)
            localVerifyStruct(data);

            obj.Format2Data=data;
        end

        function set.Format3Data(obj,data)
            localVerifyObject(data);

            obj.Format3Data=data;
        end

        function VerStr=get.RequiredMatlabVersionString(obj)

            VerNum=obj.RequiredMatlabVersion;
            if VerNum>0
                Major=fix(VerNum/10000);
                Minor=fix((VerNum-Major*10000)/100);
                Rev=fix((VerNum-Major*10000-Minor*100));
                VerStr=sprintf('%d.%d.%d',Major,Minor,Rev);
            else
                VerStr='0.0.0';
            end
        end
    end
end


function hgS=localDefaultV2Struct()


    hgS=struct(...
    'type',{},...
    'handle',{},...
    'properties',{},...
    'children',{},...
    'special',{});
end


function localVerifyStruct(data)
    ExpStruct=localDefaultV2Struct;


    OK=length(fieldnames(data))==length(fieldnames(ExpStruct))...
    &&all(strcmp(fieldnames(data),fieldnames(ExpStruct)));

    if~OK
        E=MException(message('MATLAB:graphics:internal:figfile:FigFile:InvalidFormat2Data'));
        throwAsCaller(E);
    end
end


function localVerifyObject(data)

    OK=isempty(data)...
    ||(isvector(data)&&localIsHG(data));

    if~OK
        E=MException(message('MATLAB:graphics:internal:figfile:FigFile:InvalidFormat3Data'));
        throwAsCaller(E);
    end
end


function isHG=localIsHG(hndls)

    isHG=all(ishghandle(hndls));
end
