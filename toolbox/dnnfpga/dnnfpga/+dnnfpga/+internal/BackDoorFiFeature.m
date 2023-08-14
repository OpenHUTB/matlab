classdef BackDoorFiFeature<handle

    properties


        OrigFixPtLicenseFeatureValue=0;
    end

    methods

        function this=BackDoorFiFeature()

        end

        function enable(this)






















            this.OrigFixPtLicenseFeatureValue=fifeature('DLHDLTBX_CUST_INT');
            fifeature('DLHDLTBX_CUST_INT',1);
        end

        function disable(this)


            fifeature('DLHDLTBX_CUST_INT',this.OrigFixPtLicenseFeatureValue);
        end
    end



end
