classdef Slice<handle&matlab.mixin.SetGet




    events



SliceUpdated

    end


    properties(SetAccess=private,Hidden,Transient)

        Current(1,1)double{mustBePositive(Current),mustBeInteger(Current)}=1;

        Max(1,1)double{mustBePositive(Max),mustBeInteger(Max)}=1;

        Dimension(1,1)double=3;

        LastKnownSlice(1,3)double=[1,1,1];

    end


    methods




        function nextSlice(self)



            if self.Current<self.Max
                self.Current=self.Current+1;
                update(self);
            end

        end




        function previousSlice(self)



            if self.Current>1
                self.Current=self.Current-1;
                update(self);
            end

        end




        function sliceAtIndex(self,idx)




            if idx>0&&idx<=self.Max
                self.Current=idx;
                update(self);
            end

        end




        function clear(self)



            self.Current=1;
            self.Max=1;
            self.LastKnownSlice=[1,1,1];

        end




        function reset(self,sz)




            self.Max=sz(self.Dimension);
            sliceAtIndex(self,1);

        end




        function setDimension(self,dim,sz)




            if dim==1||dim==2||dim==3

                self.Dimension=dim;

                if~isempty(sz)&&all(sz~=0)




                    self.Max=sz(self.Dimension);
                    sliceAtIndex(self,self.LastKnownSlice(dim));
                end

            end

        end

    end


    methods(Access=protected)


        function update(self)
            self.LastKnownSlice(self.Dimension)=self.Current;
            notify(self,'SliceUpdated');
        end

    end

end