



classdef NameUtils<handle
    properties(Constant,Access=public)
        MaxIters=1000;
    end


    methods(Access=public)
        function oMdlName=getValidModelName(this,ssBlkH,varargin)
            narginchk(2,4)
            base_name=get_param(ssBlkH,'Name');
            modelName=bdroot(ssBlkH);
            dataAccessor=Simulink.data.DataAccessor.createForExternalData(modelName);


            switch(nargin)
            case 2
                maxIters=this.MaxIters;
                excludedNames={};
            case 3
                maxIters=varargin{1};
                excludedNames={};
            case 4
                maxIters=varargin{1};
                excludedNames=varargin{2};
            end

            base_name=Simulink.ModelReference.Conversion.NameUtils.getModelNameFromBaseName(base_name);



            maxIdLength=get_param(bdroot(ssBlkH),'MaxIdLength');
            maxLen=min(namelengthmax,maxIdLength)-3;
            if(length(base_name)>maxLen)
                base_name=base_name(1:maxLen);
            end


            if strcmpi(base_name,'matrix')||strcmpi(base_name,'vector')
                base_name=[base_name,'0'];
            end

            startIndex=0;
            oMdlName=Simulink.ModelReference.Conversion.NameUtils.getValidModelNameForBase(...
            base_name,maxIters,dataAccessor,startIndex,excludedNames);
        end
    end

    methods(Static,Access=public)
        function status=isValidNewModelName(dataAccessor,modelName,excludedNames)
            if isa(dataAccessor,'Simulink.data.DataAccessor')
                isObjExist=~isempty(dataAccessor.identifyByName(modelName));
            else
                isObjExist=dataAccessor.exist(modelName);
            end
            status=~Simulink.ModelReference.Conversion.NameUtils.doesModelNameExist(modelName)&&...
            ~isObjExist&&...
            ~any(strcmp(modelName,excludedNames));
        end


        function status=doesModelNameExist(modelName)
            existVal=exist(modelName);%#ok
            status=~((existVal==0)||(existVal==7));
        end


        function status=isModelNameValid(modelName)
            status=ischar(modelName)&&isvarname(modelName);
        end

        function modelName=getValidModelNameForBase(suggestedName,maxIters,dataAccessor,startIndex,varargin)
            narginchk(4,5);

            if isempty(varargin)
                excludedNames={};
            else
                excludedNames=varargin{1};
            end

            maxLength=namelengthmax-4;


            suggestedName=matlab.lang.makeValidName(suggestedName);


            suggestedName=suggestedName(1:min(maxLength,length(suggestedName)));
            if~Simulink.ModelReference.Conversion.NameUtils.isValidNewModelName(dataAccessor,suggestedName,excludedNames)
                modelName='';

                iter=startIndex;
                while(iter<maxIters)
                    tmpModelName=sprintf('%s%d',suggestedName,iter);


                    while(length(tmpModelName)>maxLength)
                        suggestedName=suggestedName(1:(end-1));
                        if(isempty(suggestedName))


                            return;
                        end
                        tmpModelName=sprintf('%s%d',suggestedName,iter);
                    end

                    if Simulink.ModelReference.Conversion.NameUtils.isValidNewModelName(dataAccessor,tmpModelName,excludedNames)
                        modelName=tmpModelName;
                        break;
                    end

                    iter=iter+1;
                end
            else
                modelName=suggestedName;
            end
        end


        function modelName=getModelNameFromBaseName(baseName)

            modelName=regexprep(baseName,'[^a-zA-Z0-9_]+','_');


            modelName=regexprep(modelName,'(^_+|_+$)','');


            if isempty(modelName)
                modelName='modelref';
            end
        end
    end
end


