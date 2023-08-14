classdef LookupTableControl<lutdesigner.access.Access

    properties(Constant)
        Type='lookupTableControl'
    end

    properties(SetAccess=immutable)
Path
    end

    properties(SetAccess=immutable)
OwnerPath
ControlName
    end

    methods
        function this=LookupTableControl(ownerPath,controlName)
            this.OwnerPath=regexprep(ownerPath,'\n',' ');
            this.ControlName=controlName;
            this.Path=sprintf('%s/%s',this.OwnerPath,this.ControlName);
        end

        function tf=isAvailable(this)
            if isvarname(this.OwnerPath)
                if~bdIsLoaded(this.OwnerPath)
                    tf=false;
                    return;
                end
            else
                if getSimulinkBlockHandle(this.OwnerPath)<=0||...
                    lutdesigner.access.internal.isBlockCommentedOut(this.OwnerPath)
                    tf=false;
                    return;
                end
            end

            tf=lutdesigner.lutfinder.LookupTableFinder.hasLookupTableControl(this.OwnerPath,'Visible','on')&&...
            isa(Simulink.Mask.get(this.OwnerPath).getDialogControl(this.ControlName),'Simulink.dialog.LookupTableControl');
        end

        function tf=contains(this,that)
            tf=isequal(this,that);
        end

        function show(this)
            parentAccess=lutdesigner.access.Access.fromSimulinkComponent(this.OwnerPath);
            parentAccess.show();
        end
    end

    methods
        function accessDescs=getSubAccessDescs(this)
            accessDescs=this.createDescArray([0,1]);
        end

        function lutProxy=getDataProxy(this)
            lutProxy=lutdesigner.lutfinder.LookupTableFinder.getLookupTableControlDataProxy(char(this.OwnerPath),this.ControlName);
        end
    end
end
