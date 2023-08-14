classdef ScaleLabels<handle




    properties

UniqueLabels

    end

    properties(Access=protected)

LUT

    end

    methods

        function self=ScaleLabels(labels)

            switch class(labels)

            case{'uint8','uint16'}

                tmp=zeros(1,256);
                tmp(labels(labels>0))=1;
                labelIdx=find(tmp);

                if any(labels(:)==0)
                    labelIdx=[0,labelIdx];
                end

                self.UniqueLabels=labelIdx;
                numLabels=length(labelIdx);

                classLabels=class(labels);
                if isequal(classLabels,'uint8')
                    self.LUT=zeros(1,256,'uint8');

                elseif isequal(classLabels,'uint16')
                    self.LUT=zeros(1,65536,'uint16');

                end

                self.LUT(self.UniqueLabels+1)=1:numLabels;

            otherwise

                self.UniqueLabels=unique(labels);

            end

        end

        function labelsScaled=scale(self,labels)

            switch class(labels)

            case{'uint8','uint16'}
                labelsScaled=intlut(labels,self.LUT);

            otherwise

                labelsScaled=uint8(labels);
                for i=1:length(self.UniqueLabels)
                    idx=labels==self.UniqueLabels(i);
                    labelsScaled(idx)=i;
                end

            end

        end

    end

end
