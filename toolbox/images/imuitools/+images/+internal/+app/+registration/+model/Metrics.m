classdef Metrics<handle



    properties
ssim
    end

    methods

        function self=Metrics()
        end

        function getAlignmentQuality(self,A,ref)

            if~isa(A,class(ref))||islogical(A)||islogical(ref)
                A=im2double(A);
                ref=im2double(ref);
            end

            if isa(A,'int16')




                L=max(1,max(A(:))-min(A(:)));
                self.ssim=ssim(A,ref,'DynamicRange',L);%#ok<CPROPLC>
            else
                self.ssim=ssim(A,ref);%#ok<CPROPLC>
            end

        end

    end

end