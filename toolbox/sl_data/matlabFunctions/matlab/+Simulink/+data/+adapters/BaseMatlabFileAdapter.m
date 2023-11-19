classdef BaseMatlabFileAdapter<handle

    properties
source
section
    end

    methods(Abstract)

        name=getAdapterName(this)
        extensions=getSupportedExtensions(this)
        diagnostic=getData(this,sourceWorkspace,prevChecksum,diagnostic)
    end

    methods


        function retVal=isSourceValid(this,Source)
            retVal=false;
            dirStruct=dir(Source);
            if(isempty(dirStruct))
                return;
            end
            [~,~,ext]=fileparts(Source);
            if~(any(strcmpi(this.getSupportedExtensions,ext)))
                return;
            end
            retVal=true;
        end




        function retVal=supportsReading(this,Source)
            retVal=false;

            if this.isSourceValid(Source)
                [~,attribs]=fileattrib(Source);
                if(attribs.UserRead==1)
                    retVal=true;
                end
            end
        end


        function retval=open(this,source,section)
            this.source=source;
            this.section=section;
            retval=true;
        end


        function retval=close(this)
            this.source='';
            retval=true;
        end



        function currentChecksum=getCurrentChecksum(this)
            fileInfo=dir(this.source);
            currentChecksum=fileInfo.date;
        end



        function sections=getSectionNames(this,source)%#ok<INUSD> 
            sections={this.getAdapterName()};
        end

    end

    methods(Hidden)
        function retVal=supportsWriting(this,Source)
            retVal=true;
            if this.isSourceValid(Source)
                [~,attribs]=fileattrib(Source);
                if(attribs.UserWrite==0)
                    retVal=false;
                end
            else


                [dir,~,~]=fileparts(Source);
                [~,attribs]=fileattrib(dir);
                if(attribs.UserWrite==0)
                    retVal=false;
                end
            end
        end

        function diagnostic=writeData(this,sourceWorkspace,changeReport,diagnostic)%#ok<INUSD> 
            diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.Unsupported;
            diagnostic.DiagnosticMessage="Write functionality is unimplemented";
        end

        function retVal=hasData(this)
            w=matlab.internal.lang.Workspace;
            diag;
            this.getData(w,'',diag);
            if isempty(listVariables(w))
                retVal=true;
            else
                retVal=false;
            end
        end

    end
end
