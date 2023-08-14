



classdef SampleApp3Context<dig.CustomContext
    methods(Access=public)
        function this=SampleApp3Context()
            app=dig.Configuration.get().getApp('sampleApp3');
            this@dig.CustomContext(app);
        end

        function enableSupplementalContext(this,value)
            suppContextName='sampleApp3SupplementalContext';

            if value
                hasSuppContext=any(cellfun(strcmp(this.TypeChain,suppContextName)));
                if~hasSuppContext
                    this.TypeChain=[this.TypeChain,suppContextName];
                end
            else
                this.TypeChain=setdiff(this.TypeChain,suppContextName,'stable');
            end
        end
    end

    methods(Static)
        function[actionName,text,description]=getSystemSelectorConvertButtonProperties()
            actionName='testSystemSelectorAction';
            text='Convert Test';
            description='Convert Test Description';
        end

        function licenses=licensesToCheckout(newLicenses)
            persistent gLicenses;
            if isempty(gLicenses)
                gLicenses={};
            end

            licenses=gLicenses;

            if nargin>0&&iscell(newLicenses)
                valid=true;
                numElements=numel(newLicenses);
                for index=1:numElements
                    if~ischar(newLicenses{index})
                        valid=false;
                        break;
                    end
                end

                if valid
                    gLicenses=newLicenses;
                end
            end
        end
    end
end