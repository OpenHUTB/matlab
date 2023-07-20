classdef ErrorHandler<handle




    properties(SetAccess=immutable)

        MessageCatalog(1,1)string

        TagPrefix(1,1)string

ParentContainer
    end

    properties

        ShowErrorPath(1,1)logical=false;


        DebugMode(1,1)logical=false;
    end

    methods
        function this=ErrorHandler(msgCatalog,tagPrefix,parent)

            assert(isequal(nargin,3));
            this.ParentContainer=parent;
            this.MessageCatalog=msgCatalog;
            this.TagPrefix=tagPrefix;
        end

        function showErrorDialog(this,ME)




            if isempty(ME)

                return;
            end


            errStruct=parseErrorDetails(this,ME);
            if this.DebugMode
                if isa(ME,'MException')
                    exception=MException(ME.identifier,'%s',ME.getReport);
                    throw(exception);
                else
                    error(errStruct);
                end
            end


            try
                titleStr=getString(message(errStruct.identifier));
            catch

                titleStr=getString(message(strcat(this.MessageCatalog,':ErrorDialogTitle')));
            end

            this.ParentContainer.CustomDialogInterface.getUIAlert(errStruct.message,titleStr);
        end
    end

    methods(Access=protected)
        function errStruct=parseErrorDetails(this,ME)


            errStruct=struct('identifier','','message','','stack',{});
            if isa(ME,'MException')
                msg=strtrim(ME.message);
                if this.ShowErrorPath
                    msgReport=getReport(ME,'extended','hyperlinks','off');
                    msgReport=strsplit(msgReport,'\n');
                    msgIdx=find(strcmp(msgReport,msg));
                    if~isempty(msgIdx)&&(length(msgReport)>msgIdx)

                        msg=[msg;msgReport(msgIdx+1)];
                    end
                end
                errStruct=struct('identifier',ME.identifier,...
                'message',msg,'stack',ME.stack);
            elseif ischar(ME)

                currStack=dbstack(2,'-completenames');
                errStruct=struct('identifier',...
                strcat(this.MessageCatalog,':UnknownError'),...
                'message',ME,'stack',currStack);
            end
        end
    end
end


