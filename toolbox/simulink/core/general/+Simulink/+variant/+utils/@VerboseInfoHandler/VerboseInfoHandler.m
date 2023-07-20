classdef(Sealed,Hidden)VerboseInfoHandler<handle




    properties(Transient,SetAccess=private)


        VerboseFlag(1,1)logical=false;


        FrameHandle=[];


        CalledFromUI(1,1)logical=false;

    end

    methods


        function obj=VerboseInfoHandler(rOptsStruct)


            if nargin==0
                return;
            end



            obj.VerboseFlag=rOptsStruct.Verbose;
            obj.FrameHandle=rOptsStruct.UIFrameHandle;
            obj.CalledFromUI=rOptsStruct.CalledFromUI;

        end

        function delete(obj)

            obj.VerboseFlag=false;
            obj.FrameHandle=[];

        end

        function flag=isCalledFromVM(obj)

            flag=~isempty(obj.FrameHandle)||obj.CalledFromUI;

        end

        function flag=getVerboseFlag(obj)

            flag=obj.VerboseFlag;

        end

    end

end
