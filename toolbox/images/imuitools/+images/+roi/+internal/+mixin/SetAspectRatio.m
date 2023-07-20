classdef(Abstract)SetAspectRatio<handle




    properties(Dependent)






AspectRatio









FixedAspectRatio

    end

    properties(Hidden,Access=protected)
        AspectRatioInternal double=1;
        FixedAspectRatioInternal=false;
        HeightInternal=[];
        WidthInternal=[];
    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)
        ShiftKeyPressed=false;
CachedHeight
CachedWidth
    end

    methods(Access=protected)


        function w=getWidth(self,h)
            if self.ShiftKeyPressed||self.FixedAspectRatioInternal
                w=h/self.AspectRatioInternal;
            else
                w=self.WidthInternal;
            end
        end


        function h=getHeight(self,w)
            if self.ShiftKeyPressed||self.FixedAspectRatioInternal
                h=w*self.AspectRatioInternal;
            else
                h=self.HeightInternal;
            end
        end


        function w=getFixedWidth(self,h)


            if self.ShiftKeyPressed
                w=h;
            else
                w=h/self.AspectRatioInternal;
            end
        end


        function toggleFixAspectRatio(self)
            self.FixedAspectRatioInternal=~self.FixedAspectRatioInternal;
        end


        function updateAspectRatio(self)
            if~isempty(self.HeightInternal)&&~isempty(self.WidthInternal)
                self.AspectRatioInternal=self.HeightInternal/self.WidthInternal;
            end
        end


        function setAspectRatioContextMenuCheck(self,cMenu)
            hobj=findall(cMenu,'Type','uimenu','Tag','IPTROIContextMenuAspectRatio');
            if~isempty(hobj)

                if isnan(self.AspectRatioInternal)
                    hobj.Enable='off';
                else
                    hobj.Enable='on';
                end

                if self.FixedAspectRatioInternal
                    hobj.Checked='on';
                else
                    hobj.Checked='off';
                end
            end
        end


        function scrollToAdjustAspectRatio(self,evt)

            isIncreaseAR=evt.VerticalScrollCount>0;
            scaleFactor=1.1;

            if isIncreaseAR
                candidateAR=self.AspectRatioInternal.*scaleFactor;
            else
                candidateAR=self.AspectRatioInternal./scaleFactor;
            end

            if candidateAR>0
                self.AspectRatioInternal=candidateAR;
            end

        end

    end

    methods





        function set.AspectRatio(self,val)

            validateattributes(val,{'numeric'},...
            {'nonempty','real','scalar','nonnegative','nonsparse'},...
            mfilename,'AspectRatio');

            val=double(val);

            if self.FixedAspectRatioInternal&&isnan(val)
                error(message('images:imroi:fixedNaNAspectRatio'));
            end

            if~isempty(self.HeightInternal)&&~isempty(self.WidthInternal)
                if isnan(val)
                    self.WidthInternal=0;
                    self.HeightInternal=0;
                elseif isinf(val)
                    self.WidthInternal=0;
                elseif val>self.AspectRatioInternal
                    self.WidthInternal=self.HeightInternal/val;
                else
                    self.HeightInternal=self.WidthInternal*val;
                end
            end

            self.AspectRatioInternal=val;


            update(self);
        end

        function val=get.AspectRatio(self)
            val=self.AspectRatioInternal;
        end




        function set.FixedAspectRatio(self,TF)
            validateattributes(TF,{'logical','numeric'},...
            {'nonempty','real','scalar','nonsparse'},...
            mfilename,'FixedAspectRatio');

            if isnan(self.AspectRatioInternal)
                error(message('images:imroi:fixedNaNAspectRatio'));
            end

            self.FixedAspectRatioInternal=logical(TF);


            update(self);
        end

        function TF=get.FixedAspectRatio(self)
            TF=self.FixedAspectRatioInternal;
        end

    end

end