classdef CompositeAdapter<images.blocked.Adapter





















    properties(Access=private)

ActiveLevel
Info

        OrigSource=[]
        OrigAdapter=[]
        ResizedSource=[]
        ResizedAdapter=[]
    end

    methods

        function obj=CompositeAdapter(originalBlockedImage,resizedBlockedImage)

            assert(originalBlockedImage.NumLevels==1,'Original BlockedImage has more than one level');

            obj.OrigSource=originalBlockedImage.Source;
            obj.OrigAdapter=originalBlockedImage.Adapter;

            obj.ResizedSource=resizedBlockedImage.Source;
            obj.ResizedAdapter=resizedBlockedImage.Adapter;

        end

    end


    methods
        function openToRead(obj,~)

            obj.OrigAdapter.openToRead(obj.OrigSource);
            obj.ResizedAdapter.openToRead(obj.ResizedSource);

            origInfo=obj.OrigAdapter.getInfo();
            resizedInfo=obj.ResizedAdapter.getInfo();

            obj.Info.Size=[origInfo.Size;resizedInfo.Size];
            obj.Info.IOBlockSize=[origInfo.IOBlockSize;resizedInfo.IOBlockSize];
            obj.Info.Datatype=[origInfo.Datatype;resizedInfo.Datatype];
            obj.Info.InitialValue=cast(0,origInfo.Datatype(1));
            obj.Info.UserData=images.blocked.internal.loadDescription(obj.OrigSource);

            obj.ActiveLevel=1;

        end

        function info=getInfo(obj)
            info=obj.Info;
        end

        function data=getIOBlock(obj,ioBlockSub,level)

            if level==1
                data=getIOBlock(obj.OrigAdapter,ioBlockSub,level);
            else
                data=getIOBlock(obj.ResizedAdapter,ioBlockSub,level-1);
            end

            obj.ActiveLevel=level;

        end
    end
end