classdef Summary<handle




    events


SummaryUpdated

    end


    properties(SetAccess=private,Transient)







        Data(:,1)single

    end


    methods




        function regenerate(self,label,dim,selectedLabel)









            self.Data=create(self,label,dim,selectedLabel);

            update(self);

        end




        function regenerateSlice(self,slice,idx,selectedLabel)







            if any(slice==selectedLabel,'all')

                self.Data(idx)=2;

            elseif any(slice~=0,'all')

                self.Data(idx)=1;

            else

                self.Data(idx)=0;

            end

            update(self);

        end




        function clear(self)


            self.Data=zeros([100,1]);

            update(self);

        end




        function summary=create(~,label,dim,selectedLabel)













            mask=label~=0;

            switch dim

            case 1
                TF=squeeze(any(any(mask,2),3));
            case 2
                TF=squeeze(any(any(mask,1),3));
            case 3
                TF=squeeze(any(any(mask,1),2));

            end

            summary=zeros(size(TF),'single');
            summary(TF)=1;




            if selectedLabel~=0
                mask=label==selectedLabel;

                switch dim

                case 1
                    TF=squeeze(any(any(mask,2),3));
                case 2
                    TF=squeeze(any(any(mask,1),3));
                case 3
                    TF=squeeze(any(any(mask,1),2));

                end

                summary(TF)=2;
            end

        end

    end


    methods(Access=protected)


        function update(self)


            if~isempty(self.Data)
                notify(self,'SummaryUpdated');
            end

        end

    end

end