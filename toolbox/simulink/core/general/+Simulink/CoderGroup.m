



classdef CoderGroup<matlab.mixin.Copyable


    properties




        Name{matlab.internal.validation.mustBeASCIICharRowVector(Name,'Name')}=''




        Description char=''




        Implementation{matlab.internal.validation.mustBeASCIICharRowVector(Implementation,'Implementation')}=''






        MemorySection{matlab.internal.validation.mustBeASCIICharRowVector(MemorySection,'MemorySection')}=''










        DataInit{matlab.internal.validation.mustBeASCIICharRowVector(DataInit,'DataInit')}='Dynamic'









        AsStructure{matlab.internal.validation.mustBeASCIICharRowVector(AsStructure,'AsStructure')}='InSelf';







        DataInstantiation{matlab.internal.validation.mustBeASCIICharRowVector(DataInstantiation,'DataInstantiation')}='PerInstance';





        DataScope{matlab.internal.validation.mustBeASCIICharRowVector(DataScope,'DataScope')}='Exported'







        HeaderFile{matlab.internal.validation.mustBeASCIICharRowVector(HeaderFile,'HeaderFile')}='$N.h'







        DefinitionFile{matlab.internal.validation.mustBeASCIICharRowVector(DefinitionFile,'DefinitionFile')}='$N.c'






        StructureTypeName{matlab.internal.validation.mustBeASCIICharRowVector(StructureTypeName,'StructureTypeName')}='$R$N$G$M'








        StructureInstanceName{matlab.internal.validation.mustBeASCIICharRowVector(StructureInstanceName,'StructureInstanceName')}='$G$N$M'





        StructureArgumentName{matlab.internal.validation.mustBeASCIICharRowVector(StructureArgumentName,'StructureArgumentName')}='$R$G_arg$M'







        StructureReferenceName{matlab.internal.validation.mustBeASCIICharRowVector(StructureReferenceName,'StructureReferenceName')}='$N$G_ref$M'







        SelfStructureTypeName{matlab.internal.validation.mustBeASCIICharRowVector(SelfStructureTypeName,'SelfStructureTypeName')}='$R_IMPL$M'









        SelfStructureInstanceName{matlab.internal.validation.mustBeASCIICharRowVector(SelfStructureInstanceName,'SelfStructureInstanceName')}='$N$M'






        SelfStructureArgumentName{matlab.internal.validation.mustBeASCIICharRowVector(SelfStructureArgumentName,'SelfStructureArgumentName')}='self$M'








        SelfStructureReferenceName{matlab.internal.validation.mustBeASCIICharRowVector(SelfStructureReferenceName,'SelfStructureReferenceName')}='$N_ref$M'





        ParameterAccessMacroName{matlab.internal.validation.mustBeASCIICharRowVector(ParameterAccessMacroName,'ParameterAccessMacroName')}='$R$U$N$M'





        AccessMethod=''

    end

    methods
        function obj=CoderGroup(varargin)
            narginchk(0,1);
            if nargin==1
                obj.Name=varargin{1};
            end
        end

        function set.Name(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if isvarname(val)
                if strcmpi(val,'Default')
                    DAStudio.error('Simulink:Data:InValid_CoderGroupName_Default');
                else
                    obj.Name=val;
                end
            else
                if isempty(val)
                    DAStudio.error('Simulink:Data:InValid_EmptyCoderGroupName');
                else
                    DAStudio.error('Simulink:Data:InValid_CoderGroupName');

                end

            end
        end

        function set.Implementation(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if any(strcmp(val,{'SingleInstance','MultiInstance'}))
                obj.Implementation=val;
            else
                DAStudio.error('Simulink:Data:InValid_CoderGroupImplementationValue',val);
            end
        end
        function set.MemorySection(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if isvarname(val)||isempty(val)
                obj.MemorySection=val;
            else
                DAStudio.error('Simulink:Data:InValid_CoderGroupMemorySectionName');
            end
        end

        function set.DataInit(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if any(strcmp(val,{'Static','Dynamic','None','Auto'}))
                obj.DataInit=val;
            else
                DAStudio.error('Simulink:Data:InValid_CoderGroupDataInitValue',val);
            end
        end

        function set.AsStructure(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if any(strcmp(val,{'InParent','InSelf','Standalone','None'}))
                obj.AsStructure=val;
            else
                DAStudio.error('Simulink:Data:InValid_CoderGroupAsStructureValue',val);
            end
        end

        function set.DataInstantiation(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if any(strcmp(val,{'PerInstance','Shared','Local'}))
                obj.DataInstantiation=val;
            else
                DAStudio.error('Simulink:Data:InValid_CoderGroupDataInstantiationValue',val);
            end
        end

        function set.DataScope(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if any(strcmp(val,{'Imported','Exported'}))
                obj.DataScope=val;
            else
                DAStudio.error('Simulink:Data:InValid_CoderGroupDataScopeValue',val);
            end
        end

        function set.HeaderFile(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$N, $G, $R and $U';
            if(~isempty(val))
                [~,name,ext]=fileparts(val);
                if(strcmp(name,'$R')==0)
                    Simulink.CoderGroup.validateAndThrowForNamingProperties(name,validTokens,'HeaderFile');
                    obj.HeaderFile=[name,ext];
                else
                    DAStudio.error('Simulink:Data:Invalid_HeaderFileToken','HeaderFile');
                end
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'HeaderFile');
            end
        end

        function set.DefinitionFile(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$N, $G, $R and $U';
            if(~isempty(val))
                [~,name,ext]=fileparts(val);
                if(strcmp(name,'$R')==0)
                    Simulink.CoderGroup.validateAndThrowForNamingProperties(name,validTokens,'DefinitionFile');
                    obj.DefinitionFile=[name,ext];
                else
                    DAStudio.error('Simulink:Data:Invalid_DefinitionFileToken','DefinitionFile');
                end
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'DefinitionFile');
            end
        end

        function set.StructureTypeName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $N, $G, $U and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'StructureTypeName');
                obj.StructureTypeName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'StructureTypeName');
            end
        end

        function set.StructureInstanceName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $N, $G , $U and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'StructureInstanceName');
                obj.StructureInstanceName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'StructureInstanceName');
            end
        end

        function set.StructureArgumentName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $N, $G, $U, $I and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'StructureArgumentName');
                obj.StructureArgumentName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'StructureArgumentName');
            end
        end

        function set.StructureReferenceName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $N, $G, $U and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'StructureReferenceName');
                obj.StructureReferenceName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'StructureReferenceName');
            end
        end

        function set.SelfStructureTypeName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $G, $U and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'SelfStructureTypeName');
                obj.SelfStructureTypeName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'SelfStructureTypeName');
            end
        end

        function set.SelfStructureInstanceName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $N, $G, $U and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'SelfStructureInstanceName');
                obj.SelfStructureInstanceName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'SelfStructureInstanceName');
            end
        end

        function set.SelfStructureArgumentName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $G, $U, $I and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'SelfStructureArgumentName');
                obj.SelfStructureArgumentName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'SelfStructureArgumentName');
            end
        end

        function set.SelfStructureReferenceName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $N, $G, $U and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'SelfStructureReferenceName');
                obj.SelfStructureReferenceName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'SelfStructureReferenceName');
            end
        end

        function set.ParameterAccessMacroName(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$R, $G, $N, $U and $M';
            if(~isempty(val))
                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'ParameterAccessMacroName');
                obj.ParameterAccessMacroName=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'ParameterAccessMacroName');
            end
        end

        function set.AccessMethod(obj,val)
            if isvarname(val)||isempty(val)
                obj.AccessMethod=val;
            else
                DAStudio.error('Simulink:Data:InValid_CoderGroupAccessMethodName',val);
            end
        end
    end

    methods(Static,Hidden)
        function[invalidMacro,invalidStr,repeatedMacro]=validateTokensAndStrings(value,validMacros)
            invalidMacro=[];
            invalidStr=[];
            repeatedMacro=[];
            validDecorators='[u], [u_] , [l], [l_] [uL], [uL_], [lU], [lU_], [U], [U_], [L] and [L_]';
            [~,userString]=regexp(value,'[$].|\[(.*?)\]','match','split');
            [decorators,~]=regexp(value,'[(.*?)\]','match','split');
            [tokens,~]=regexp(value,'[$].','match','split');


            [~,i,~]=unique(tokens,'first');
            indexToDupes=find(not(ismember(1:numel(tokens),i)));
            if(indexToDupes>1)
                repeatedMacro=tokens{indexToDupes};
                return;
            end

            for i=1:length(tokens)
                if isempty(strfind(validMacros,tokens{i}))
                    invalidMacro=tokens{i};
                    return;
                end
            end


            for i=1:length(decorators)
                if isempty(strfind(validDecorators,decorators{i}))
                    invalidStr=decorators{i};
                    return;
                end
            end


            for i=1:length(userString)
                if~isempty(userString{i})
                    currentString=userString{i};


                    if(currentString(1)=='_')
                        index=regexp(value,currentString);
                        if(~isempty(find(index==1,1)))
                            invalidStr=userString{i};
                            return
                        end
                    elseif~isvarname(currentString)
                        A=isstrprop(currentString,'digit');
                        if(i~=1)&&(A(1)==1)
                            return;
                        else
                            invalidStr=userString{i};
                            return;
                        end
                    end
                end
            end
        end

        function validateAndThrowForNamingProperties(value,validTokens,property)
            [invalidMacro,invalidStr,repeatedMacro]=Simulink.CoderGroup.validateTokensAndStrings(value,validTokens);
            if~isempty(invalidMacro)
                DAStudio.error('Simulink:Data:Invalid_CoderGroupToken',invalidMacro,property,validTokens);
            end

            if~isempty(repeatedMacro)
                DAStudio.error('Simulink:Data:RepeatedMacro',repeatedMacro,property);
            end

            if~isempty(invalidStr)
                if(strcmp(invalidStr,'Decorator'))
                    DAStudio.error('configset:diagnostics:SfsDecoratorInvalid',property);
                end
                DAStudio.error('Simulink:Data:Invalid_CoderGroupString',invalidStr,property);
            end

        end

    end

    methods(Static)
        function out=deepCopy(arr)


            out=arr;
            for i=1:length(arr)
                out{i}=arr{i}.copy;
            end
        end

    end
end


