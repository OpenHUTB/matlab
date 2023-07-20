classdef PTDSTunableParametersSpreadSheetSource<handle
    properties
        mData;
    end
    methods
        function this=PTDSTunableParametersSpreadSheetSource(hModel)

            tunableVarsName=get_param(hModel,'TunableVars');
            tunableVarsStorageClass=get_param(hModel,'TunableVarsStorageClass');
            tunableVarsTypeQualifier=get_param(hModel,'TunableVarsTypeQualifier');

            varsInStruct=[];


            sep=',';
            sepNameIndx=findstr(tunableVarsName,sep);
            sepSCIndx=findstr(tunableVarsStorageClass,sep);
            sepTQIndx=findstr(tunableVarsTypeQualifier,sep);


            if~isempty(tunableVarsName)
                numberVars=length(sepNameIndx)+1;
            else
                numberVars=0;
            end

            vars=[];
            if numberVars

                if length(sepSCIndx)+1~=numberVars
                    error=MSLException([],message('Simulink:dialog:ErrorTunableParamsStorageClassSettings',...
                    get_param(hModel,'name')));
                    sldiagviewer.reportError(error);
                    return;
                elseif length(sepTQIndx)+1~=numberVars
                    error=MSLException([],message('Simulink:dialog:ErrorTunableParamsTypeQualSettings',...
                    get_param(hModel,'name')));
                    sldiagviewer.reportError(error);
                    return;
                end

                sepNameIndx=[0,sepNameIndx,length(tunableVarsName)+1];
                sepSCIndx=[0,sepSCIndx,length(tunableVarsStorageClass)+1];
                sepTQIndx=[0,sepTQIndx,length(tunableVarsTypeQualifier)+1];

                for i=1:numberVars

                    vars(i).name=this.deblankall(tunableVarsName(sepNameIndx(i)+1:...
                    sepNameIndx(i+1)-1));
                    if~this.validate(vars(i).name)
                        warnState=warning('off','backtrace');
                        warning('on','Simulink:dialog:InvalidVarChkCommandWindow');
                        MSLDiagnostic('Simulink:dialog:InvalidVarChkCommandWindow',...
                        vars(i).name,...
                        ['get_param(''',get_param(hModel,'Name'),''', ''TunableVars'')']).reportAsWarning;
                        warning(warnState);
                    end


                    vars(i).storageclass=this.deblankall(...
                    tunableVarsStorageClass(sepSCIndx(i)+1:sepSCIndx(i+1)-1));
                    if strcmp(lower(vars(i).storageclass),'auto')
                        vars(i).storageclass='Model default';
                    elseif strcmp(lower(vars(i).storageclass),'exportedglobal')
                        vars(i).storageclass='ExportedGlobal';
                    elseif strcmp(lower(vars(i).storageclass),'importedextern')
                        vars(i).storageclass='ImportedExtern';
                    elseif strcmp(lower(vars(i).storageclass),'importedexternpointer')
                        vars(i).storageclass='ImportedExternPointer';
                    end


                    if isempty(tunableVarsTypeQualifier(sepTQIndx(i)+1:sepTQIndx(i+1)-1))
                        vars(i).typequalifier='';
                    else
                        vars(i).typequalifier=tunableVarsTypeQualifier(sepTQIndx(i)+1:...
                        sepTQIndx(i+1)-1);
                    end
                end

            end

            varsInStruct=vars;
            for i=1:numel(varsInStruct)
                this.addNewRow(varsInStruct(i).name,varsInStruct(i).storageclass,varsInStruct(i).typequalifier);
            end
        end

        function children=getChildren(obj,component)
            children=[];
            if isempty(obj.mData)
                obj.mData=children;
            else
                children=obj.mData;
            end
        end

        function addNewRow(obj,varName,varStorageclass,varTypequalifier)
            for i=1:numel(obj.mData)
                curmDataName=obj.mData(i).name;
                if isequal(curmDataName,varName)&&~isequal(varName,'')
                    return;
                end
            end
            childObj=Simulink.data.ParameterTuningDialog.PTDSTunableParametersSpreadSheetSourceRow(varName,varStorageclass,varTypequalifier);
            obj.mData=[obj.mData,childObj];
        end

        function removeselectedRows(obj,selections)
            for i=1:numel(selections)
                selectedObj=selections(i);
                selectedName=selectedObj{1}.name;
                for j=1:numel(obj.mData)
                    curmDataName=obj.mData(j).name;
                    if isequal(selectedName,curmDataName)
                        obj.mData(j)=[];
                        break;
                    end
                end
            end
        end

        function rows=getAllRows(obj)
            rows=obj.mData;
        end





        function valid=validate(obj,var)
            valid=isvarname(var);


        end

        function s1=deblankall(obj,s)

            s=char(s);
            if isempty(s)
                s1=s([]);
            else

                s1=strtrim(s);
            end
        end

    end
end


