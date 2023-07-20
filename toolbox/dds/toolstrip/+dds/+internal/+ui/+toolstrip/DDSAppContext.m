classdef DDSAppContext<coder.internal.toolstrip.CoderAppContext





    methods
        function obj=DDSAppContext(app,cbinfo)

            obj@coder.internal.toolstrip.CoderAppContext(app,cbinfo);
        end

        function guardAppName=getGuardAppName(~)
            guardAppName='DDS';
        end

        function updateTypeChain(obj)
            type=coder.internal.toolstrip.util.getOutputType(obj.ModelH);
            switch type
            case 'cpp'
                obj.OutputTypeContext='ddsCodeContext';
            otherwise
                obj.OutputTypeContext='customCodeContext';
            end
            updateTypeChain@coder.internal.toolstrip.CoderAppContext(obj);
        end

        function checkoutLicense(~)




            licenses={'DDS_Blockset'};
            for i=1:length(licenses)
                builtin('_license_checkout',licenses{i},'quiet');
            end
        end

        function openApp(obj,cbinfo,app,contextManager,customContext)

            ok=obj.openGuard(cbinfo);

            if ok

                coder.internal.toolstrip.CoderAppContext.flushOtherCoderApps(contextManager,app.name);


                obj.checkoutLicense();


                studio=cbinfo.studio;


                obj.preOpen(cbinfo);


                contextManager.activateApp(customContext);
                ts=studio.getToolStrip;
                ts.ActiveTab=customContext.DefaultTabName;
                customContext.updateTypeChain;


                cp=simulinkcoder.internal.CodePerspective.getInstance;
                if cp.isAvailable(studio)
                    cp.open(studio);
                end


                obj.postOpen(cbinfo);
            end
        end
    end
end


