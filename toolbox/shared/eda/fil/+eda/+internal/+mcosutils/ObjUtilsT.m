


classdef ObjUtilsT<handle


    methods(Static)




        function newObj=CopyCtor(newObj,oldObj)%#ok<INUSD>



            newObj=oldObj;

...
...
...
...
...
...
...
...
...
        end

        function newObj=PvPairCtor(newObj,varargin)
            if(mod(length(varargin),2)~=0)
                propertyNames=fieldnames(newObj);
                pnamestr=sprintf('  %s\n',propertyNames{:});
                error(message('EDALink:ObjUtilsT:MissingPvPairArg',pnamestr));
            end

            for ix=1:2:length(varargin)
                p=varargin{ix};
                v=varargin{ix+1};
                try
                    newObj.(p)=v;
                catch ME
                    error(message('EDALink:ObjUtilsT:CouldNotAssignProperty',p,ME.message()));
                end
            end
        end

        function newObj=Ctor(newObj,varargin)






            if(iscell(varargin)&&length(varargin)==1&&iscell(varargin{1}))
                varargin=varargin{:};
            end
            if(length(varargin)==1)
                if(strcmp(class(varargin{1}),class(newObj)));
                    newObj=eda.internal.mcosutils.ObjUtilsT.CopyCtor(newObj,varargin{1});
                else


                    error(message('EDALink:ObjUtilsT:BadSingleArgCtor'));
                end
            elseif(length(varargin)>1)
                newObj=eda.internal.mcosutils.ObjUtilsT.PvPairCtor(newObj,varargin{:});
            else

            end
        end






        function outVal=CheckNumeric(inVal,typeName,range,propName)
            if(isnumeric(inVal))
                outVal=cast(inVal,typeName);
                reCast=cast(outVal,class(inVal));
                if(reCast~=inVal)
                    error(message('EDALink:ObjUtilsT:NotRepresentable',mat2str(inVal),typeName,mat2str(outVal)));
                end
            else
                error(message('EDALink:ObjUtilsT:BadNumericClass',propName));
            end
            if(~(outVal>=range(1)))
                error(message('EDALink:ObjUtilsT:BadMinValue',propName,mat2str(outVal),mat2str(range(1))));
            end
            if(~(outVal<=range(2)))
                error(message('EDALink:ObjUtilsT:BadMaxValue',propName,mat2str(outVal),mat2str(range(2))));
            end
        end

        function outVal=CheckString(inVal,propName)
            if(~ischar(inVal))
                error(message('EDALink:ObjUtilsT:BadCharClass',propName));
            end
            outVal=inVal;
        end

        function outVal=CheckBool(inVal,propName)
            if(~islogical(inVal))
                error(message('EDALink:ObjUtilsT:BadBoolClass',propName));
            end
            outVal=inVal;
        end




        function outStruct=PvCellToStruct(varargin)
            if(mod(length(varargin),2)~=0)
                error(message('EDALink:ObjUtilsT:MissingArgument'));
            end
            cellvals=varargin(2:2:end);
            cellprops=varargin(1:2:end);
            outStruct=cell2struct(cellvals,cellprops,2);
        end

        function outPvCell=StructToPvCell(inStruct)
            cellvals=struct2cell(inStruct);
            cellprops=fieldnames(inStruct);
            matpv=[cellprops,cellvals];
            matpvprime=matpv';
            outPvCell=matpvprime(:);
        end

        function parsedStruct=ParsePvCellArgs(defaultPvStruct,inArgs)

            if(mod(length(inArgs),2)~=0)
                error(message('EDALink:ObjUtilsT:MissingArgumentWithValidParams',char(fieldnames(defaultPvStruct))));
            end

            parsedStruct=defaultPvStruct;
            for ix=1:2:length(inArgs)
                p=inArgs{ix};
                v=inArgs{ix+1};
                if(isfield(defaultPvStruct,p))
                    parsedStruct.(p)=v;
                else
                    error(message('EDALink:ObjUtilsT:BadParameter',p,char(fieldnames(defaultPvStruct))'));
                end
            end
        end

        function parsedStruct=ParseStructArg(defaultStruct,inArgStruct)
            inArgCell=eda.internal.mcosutils.ObjUtilsT.StructToPvCell(inArgStruct);
            parsedStruct=eda.internal.mcosutils.ObjUtilsT.ParsePvCellArgs(defaultStruct,inArgCell);
        end

        function parsedStruct=ParseArgs(defaultStruct,varargin)
            if(length(varargin)==1&&isstruct(varargin{1}))
                parsedStruct=eda.internal.mcosutils.ObjUtilsT.ParseStructArg(defaultStruct,varargin{1});
            elseif(length(varargin)==1&&iscell(varargin{1}))
                parsedStruct=eda.internal.mcosutils.ObjUtilsT.ParsePvCellArgs(defaultStruct,varargin{1});
            else
                error(message('EDALink:ObjUtilsT:BadParseArgs'));
            end
        end

    end

end
