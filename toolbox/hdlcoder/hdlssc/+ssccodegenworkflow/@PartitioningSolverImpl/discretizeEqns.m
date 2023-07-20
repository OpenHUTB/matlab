function obj=discretizeEqns(obj)








    if~isempty(obj.EqnData.DiffClumpInfo)

        Msize=size(obj.EqnData.DiffClumpInfo.MatrixInfo(1).M);

        numModes=numel(obj.EqnData.DiffClumpInfo.MatrixInfo);

        MdInv=zeros(Msize(1),Msize(2),numModes);


        for i=1:numModes
            MdInv(:,:,i)=obj.SampleTime*(obj.EqnData.DiffClumpInfo.MatrixInfo(i).M)^-1;
        end
        obj.EqnData.DiffClumpInfo.MdInv=MdInv;

        obj.EqnName.DiffClumpInfo.MdInv=strcat(obj.DataName,'.DiffClumpInfo.MdInv');


    end



    if~isempty(obj.EqnData.ClumpInfo)
        for clumpNum=1:numel(obj.EqnData.ClumpInfo)



            Msize=size(obj.EqnData.ClumpInfo(clumpNum).MatrixInfo(1).M);

            numModes=numel(obj.EqnData.ClumpInfo(clumpNum).MatrixInfo);

            MdInv=zeros(Msize(1),Msize(2),numModes);
            Ad=zeros(Msize(1),Msize(2),numModes);


            for i=1:numModes

                MdInv(:,:,i)=(obj.EqnData.ClumpInfo(clumpNum).MatrixInfo(i).M/obj.SampleTime+obj.EqnData.ClumpInfo(clumpNum).MatrixInfo(i).A)^-1;
                Ad(:,:,i)=MdInv(:,:,i)*(obj.EqnData.ClumpInfo(clumpNum).MatrixInfo(i).M)/obj.SampleTime;
            end
            obj.EqnData.ClumpInfo(clumpNum).MdInv=MdInv;
            obj.EqnData.ClumpInfo(clumpNum).Ad=Ad;

            obj.EqnName.ClumpInfo(clumpNum).MdInv=strcat(obj.DataName,'.ClumpInfo(',num2str(clumpNum),').MdInv');
            obj.EqnName.ClumpInfo(clumpNum).Ad=strcat(obj.DataName,'.ClumpInfo(',num2str(clumpNum),').Ad');


        end
    end



end




