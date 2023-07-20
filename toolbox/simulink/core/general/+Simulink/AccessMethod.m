



classdef AccessMethod<matlab.mixin.Copyable


    properties




        Name{matlab.internal.validation.mustBeASCIICharRowVector(Name,'Name')}=''




        Description char=''




        NamingRule{matlab.internal.validation.mustBeASCIICharRowVector(NamingRule,'NamingRule')}='$N'




        MemorySection{matlab.internal.validation.mustBeASCIICharRowVector(MemorySection,'MemorySection')}=''





        Latching{matlab.internal.validation.mustBeASCIICharRowVector(Latching,'Latching')}='None';





        AccessMode{matlab.internal.validation.mustBeASCIICharRowVector(AccessMode,'AccessMode')}='ByValue';





        HeaderFile{matlab.internal.validation.mustBeASCIICharRowVector(HeaderFile,'HeaderFile')}='$N.h'





        DefinitionFile{matlab.internal.validation.mustBeASCIICharRowVector(DefinitionFile,'DefinitionFile')}='$N.c'





        Scope{matlab.internal.validation.mustBeASCIICharRowVector(Scope,'Scope')}='Exported'


    end

    methods
        function obj=AccessMethod(varargin)
            narginchk(0,1);
            if nargin==1
                obj.Name=varargin{1};
            end
        end

        function set.Name(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if isvarname(val)
                obj.Name=val;
            else
                if isempty(val)
                    DAStudio.error('Simulink:Data:InValid_EmptyAccessMethodName');
                else
                    DAStudio.error('Simulink:Data:InValid_AccessMethodName');
                end
            end
        end

        function set.Description(obj,val)
            obj.Description=val;
        end

        function set.NamingRule(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$F, $N, $G, $M, $R and $U';
            if(~isempty(val))


                Simulink.CoderGroup.validateAndThrowForNamingProperties(val,validTokens,'NamingRule');
                obj.NamingRule=val;
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'NamingRule');
            end
        end

        function set.MemorySection(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if isvarname(val)||isempty(val)
                obj.MemorySection=val;
            else
                DAStudio.error('Simulink:Data:InValid_AccessMethodMemorySectionName');
            end
        end

        function set.AccessMode(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if any(strcmpi(val,{'ByValue','ByReference'}))
                obj.AccessMode=val;
            else
                DAStudio.error('Simulink:Data:InValid_AccessMethodAccessModeValue');
            end
        end

        function set.Latching(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if any(strcmpi(val,{'None','TaskEdge','MinimalLatency'}))
                obj.Latching=val;
            else
                DAStudio.error('Simulink:Data:InValid_AccessMethodLatchingValue');
            end
        end

        function set.Scope(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            if any(strcmp(val,{'Imported','Exported'}))
                obj.Scope=val;
            else
                DAStudio.error('Simulink:Data:InValid_AccessMethodScopeValue',val);
            end
        end

        function set.HeaderFile(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$N, $R, $G and $U';
            if(~isempty(val))


                includeUsingAngleBrackets=false;
                if val(1)=='<'&&val(end)=='>'
                    includeUsingAngleBrackets=true;
                    val=val(2:end-1);
                elseif val(1)=='"'&&val(end)=='"'
                    val=val(2:end-1);
                end
                [~,name,ext]=fileparts(val);
                Simulink.CoderGroup.validateAndThrowForNamingProperties(name,validTokens,'HeaderFile');
                if includeUsingAngleBrackets
                    obj.HeaderFile=['<',name,ext,'>'];
                else
                    obj.HeaderFile=[name,ext];
                end
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'HeaderFile');
            end
        end

        function set.DefinitionFile(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            validTokens='$N, $R, $G and $U';
            if(~isempty(val))


                [~,name,ext]=fileparts(val);
                Simulink.CoderGroup.validateAndThrowForNamingProperties(name,validTokens,'DefinitionFile');
                obj.DefinitionFile=[name,ext];
            else
                DAStudio.error('Simulink:Data:EmptyString',val,'DefinitionFile');
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


