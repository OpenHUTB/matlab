





classdef ActiveContourEvolver



    properties

ContourSpeed
Image

    end

    properties(SetAccess=private)

NumDimensions
NumChannels

    end

    properties(Dependent=true)

ContourState

    end

    properties(Hidden,Access=private)

ImageSize

neighs
phi
label
Lz
Ln1
Lp1
Ln2
Lp2
Lin2out
Lout2in

ContourStateHistory

hasher

    end

    properties(Hidden,Access=private,Constant=true)

        c_neighs_2D=[1,0,0;-1,0,0;0,1,0;0,-1,0];
        c_neighs_3D=[1,0,0;-1,0,0;0,1,0;0,-1,0;0,0,1;0,0,-1];

        c_contourStateHistoryLen=5;

    end



    methods

        function obj=ActiveContourEvolver(Image,ContourState,ContourSpeed)

            if size(ContourState,3)==1
                obj.NumChannels=size(Image,3);
            else
                obj.NumChannels=1;
            end

            obj.Image=Image;
            obj.ContourState=ContourState;
            obj.ContourSpeed=ContourSpeed;


            obj.hasher=matlab.internal.crypto.BasicDigester("Blake-2b");
            obj.ContourStateHistory=NaN(obj.c_contourStateHistoryLen,64);
        end

        function[obj,currentIteration]=moveActiveContour(obj,numIterations,varargin)

            validateattributes(numIterations,{'numeric'},{'nonnan',...
            'nonsparse','nonempty','finite','integer','scalar','positive'});

            if nargin>2
                useStopCriterion=varargin{1};
                validateattributes(useStopCriterion,{'numeric','logical'},...
                {'nonnan','nonsparse','nonempty','finite','integer','scalar'});
                useStopCriterion=logical(useStopCriterion);
            else
                useStopCriterion=true;
            end

            for currentIteration=1:numIterations


                F=calculateSpeed(obj.ContourSpeed,obj.Image,obj.phi,obj.Lz.idx);


                obj=updateLevelSetSFM(obj,F);


                obj.ContourSpeed=updateSpeed(obj.ContourSpeed,obj.Image,...
                obj.Lin2out.idx,obj.Lout2in.idx);

                if isempty(obj.Lz.idx)
                    warning(message('images:activecontour:vanishingContour','MASK'))
                    break;
                end

                if useStopCriterion


                    currContourState=obj.hasher.computeDigest(typecast(sort(obj.Lz.idx),'uint8'));

                    if ismember(currContourState,obj.ContourStateHistory,'rows')
                        break;
                    else
                        historyRow=rem(currentIteration-1,obj.c_contourStateHistoryLen)+1;
                        obj.ContourStateHistory(historyRow,:)=currContourState;
                    end
                end

            end

        end

        function hdl=plot(obj,varargin)

            if nargin>1
                error(message('images:activecontour:tooManyInputsInMethod',...
                'PLOT',mfilename('class')))
            else
                [~,hdl]=contour(obj.ContourState,[0,0],'r','LineWidth',2);
            end

        end



        function obj=set.ContourSpeed(obj,ContourSpeed)

            import images.activecontour.internal.ActiveContourSpeed;

            validActiveCountourSpeed=isa(ContourSpeed,'ActiveContourSpeed');

            isImageInPlace=~isempty(obj.Image);%#ok<MCSUP>
            isPhiInPlace=~isempty(obj.phi);%#ok<MCSUP>

            if~validActiveCountourSpeed
                error(message('images:activecontour:invalidSpeedObject',...
                'ContourSpeed'))
            else
                obj.ContourSpeed=ContourSpeed;
            end

            if isImageInPlace&&isPhiInPlace

                obj.ContourSpeed=initalizeSpeed(obj.ContourSpeed,...
                obj.Image,obj.phi);%#ok<MCSUP>
            end
        end

        function obj=set.ContourState(obj,ContourState)

            validateattributes(ContourState,{'numeric','logical'},{'nonnan',...
            'nonsparse','nonempty','real'});

            isImageInPlace=~isempty(obj.Image);
            isContourSpeedInPlace=~isempty(obj.ContourSpeed);

            if isImageInPlace
                if obj.NumChannels>1
                    sz=size(obj.Image);
                    if~isequal(sz(1:2),size(ContourState))
                        error(message('images:activecontour:differentMatrixSize',...
                        'Image','ContourState'))
                    end
                else
                    if~isequal(size(obj.Image),size(ContourState))
                        error(message('images:activecontour:differentMatrixSize',...
                        'Image','ContourState'))
                    end
                end
            else
                assert(false,'Error setting up activecontour. No image was loaded into the evolver, so the dimensionality is ambiguous.')
            end


            if~islogical(ContourState)
                ContourState=logical(ContourState);
            end



            ContourState(1,:,:)=false;
            ContourState(end,:,:)=false;
            ContourState(:,1,:)=false;
            ContourState(:,end,:)=false;
            if obj.NumDimensions>2&&obj.NumChannels==1
                ContourState(:,:,1)=false;
                ContourState(:,:,end)=false;
            end


            obj=initializeLevelSetSFM(obj,ContourState);

            if isImageInPlace&&isContourSpeedInPlace

                obj.ContourSpeed=initalizeSpeed(obj.ContourSpeed,...
                obj.Image,obj.phi);
            end

        end

        function obj=set.Image(obj,Image)

            validateattributes(Image,{'numeric'},{'finite','nonsparse',...
            'nonempty','real'});

            isPhiInPlace=~isempty(obj.phi);%#ok<MCSUP>
            isContourSpeedInPlace=~isempty(obj.ContourSpeed);%#ok<MCSUP>

            if isPhiInPlace
                if~isequal(size(obj.phi),size(Image))%#ok<MCSUP>
                    error(message('images:activecontour:differentMatrixSize',...
                    'Image','phi'))
                end
            else
                obj.NumDimensions=ndims(Image);%#ok<MCSUP>
                obj.ImageSize=size(Image);%#ok<MCSUP>
                if obj.NumDimensions<3 %#ok<MCSUP>
                    obj.ImageSize=[obj.ImageSize,1];%#ok<MCSUP>
                elseif obj.NumChannels>1 %#ok<MCSUP>
                    obj.ImageSize(3)=1;%#ok<MCSUP>
                end
            end

            if isinteger(Image)
                Image=single(Image);
            end
            obj.Image=Image;

            if isPhiInPlace&&isContourSpeedInPlace

                obj.ContourSpeed=initalizeSpeed(obj.ContourSpeed,...
                obj.Image,obj.phi);%#ok<MCSUP>
            end

        end

        function obj=set.NumDimensions(obj,NumDimensions)

            obj.NumDimensions=NumDimensions;
            if(obj.NumDimensions==2)||(obj.NumChannels>1)%#ok<MCSUP>
                obj.neighs=obj.c_neighs_2D;%#ok<MCSUP>
            elseif(obj.NumDimensions==3)&&(obj.NumChannels==1)%#ok<MCSUP>
                obj.neighs=obj.c_neighs_3D;%#ok<MCSUP>
            else
                error(message('images:activecontour:mustBe2Dor3D','Image or phi'))
            end

        end



        function ContourState=get.ContourState(obj)

            ContourState=obj.phi<0;

        end

    end

    methods(Hidden,Access=private)

        function obj=initializeLevelSetSFM(obj,initContour)

            import images.activecontour.internal.*;


            obj.phi=zeros(obj.ImageSize,'double');
            obj.label=zeros(obj.ImageSize,'int8');

            obj.label(initContour)=-3;
            obj.phi(initContour)=-3;

            obj.label(~initContour)=3;
            obj.phi(~initContour)=3;


            obj.Lz.idx=[];obj.Lz.r=[];obj.Lz.c=[];obj.Lz.z=[];
            if obj.NumDimensions==3&&obj.NumChannels==1
                obj.Lz.idx=find(initContour&(neighL(~initContour)|neighR(~initContour)...
                |neighU(~initContour)|neighD(~initContour)|neighF(~initContour)...
                |neighB(~initContour)));
            else
                obj.Lz.idx=find(initContour&(neighL(~initContour)|neighR(~initContour)...
                |neighU(~initContour)|neighD(~initContour)));
            end
            obj.Lz.idx=unique(obj.Lz.idx);
            [obj.Lz.r,obj.Lz.c,obj.Lz.z]=ind2sub(obj.ImageSize,obj.Lz.idx);
            obj.label(obj.Lz.idx)=0;
            obj.phi(obj.Lz.idx)=0;


            obj.Ln1.idx=[];obj.Ln1.r=[];obj.Ln1.c=[];obj.Ln1.z=[];
            obj.Lp1.idx=[];obj.Lp1.r=[];obj.Lp1.c=[];obj.Lp1.z=[];

            for i=1:size(obj.neighs,1)
                neighIdx=getNeighIdx(obj.neighs(i,:),obj.ImageSize,...
                obj.Lz.r,obj.Lz.c,obj.Lz.z);
                idx3n=obj.label(neighIdx)==-3;
                obj.Ln1.idx=[obj.Ln1.idx;neighIdx(idx3n)];
                obj.Ln1.idx=unique(obj.Ln1.idx);
                idx3p=obj.label(neighIdx)==3;
                obj.Lp1.idx=[obj.Lp1.idx;neighIdx(idx3p)];
                obj.Lp1.idx=unique(obj.Lp1.idx);
            end
            obj.label(obj.Ln1.idx)=-1;
            obj.phi(obj.Ln1.idx)=-1;
            obj.label(obj.Lp1.idx)=1;
            obj.phi(obj.Lp1.idx)=1;

            [obj.Ln1.r,obj.Ln1.c,obj.Ln1.z]=ind2sub(obj.ImageSize,obj.Ln1.idx);
            [obj.Lp1.r,obj.Lp1.c,obj.Lp1.z]=ind2sub(obj.ImageSize,obj.Lp1.idx);


            obj.Ln2.idx=[];obj.Ln2.r=[];obj.Ln2.c=[];obj.Ln2.z=[];
            obj.Lp2.idx=[];obj.Lp2.r=[];obj.Lp2.c=[];obj.Lp2.z=[];

            for i=1:size(obj.neighs,1)
                neighIdx=getNeighIdx(obj.neighs(i,:),obj.ImageSize,...
                obj.Ln1.r,obj.Ln1.c,obj.Ln1.z);
                idx3n=obj.label(neighIdx)==-3;
                obj.Ln2.idx=[obj.Ln2.idx;neighIdx(idx3n)];
                obj.Ln2.idx=unique(obj.Ln2.idx);
            end
            obj.label(obj.Ln2.idx)=-2;
            obj.phi(obj.Ln2.idx)=-2;
            for i=1:size(obj.neighs,1)
                neighIdx=getNeighIdx(obj.neighs(i,:),obj.ImageSize,...
                obj.Lp1.r,obj.Lp1.c,obj.Lp1.z);
                idx3p=obj.label(neighIdx)==3;
                obj.Lp2.idx=[obj.Lp2.idx;neighIdx(idx3p)];
                obj.Lp2.idx=unique(obj.Lp2.idx);
            end
            obj.label(obj.Lp2.idx)=2;
            obj.phi(obj.Lp2.idx)=2;

            [obj.Ln2.r,obj.Ln2.c,obj.Ln2.z]=ind2sub(obj.ImageSize,obj.Ln2.idx);
            [obj.Lp2.r,obj.Lp2.c,obj.Lp2.z]=ind2sub(obj.ImageSize,obj.Lp2.idx);

        end

        function obj=updateLevelSetSFM(obj,F)


            oldPhi=obj.phi(obj.Lz.idx);
            obj.phi(obj.Lz.idx)=(F)+oldPhi;


            obj.Lin2out.idx=[];obj.Lin2out.r=[];obj.Lin2out.c=[];obj.Lin2out.z=[];
            idxNeg2Pos=(oldPhi<=0)&(obj.phi(obj.Lz.idx)>0);
            obj.Lin2out=copyPointsToList(obj.Lz,obj.Lin2out,idxNeg2Pos);


            obj.Lout2in.idx=[];obj.Lout2in.r=[];obj.Lout2in.c=[];obj.Lout2in.z=[];
            idxPos2Neg=(oldPhi>0)&(obj.phi(obj.Lz.idx)<=0);
            obj.Lout2in=copyPointsToList(obj.Lz,obj.Lout2in,idxPos2Neg);

            [obj,Sz,Sn1,Sp1,Sn2,Sp2]=movePointsOutOfLevelSets(obj);

            obj=movePointsIntoLevelSets(obj,Sz,Sn1,Sp1,Sn2,Sp2);

        end

        function[obj,Sz,Sn1,Sp1,Sn2,Sp2]=movePointsOutOfLevelSets(...
            obj)

            import images.activecontour.internal.*;


            Sz.idx=[];Sz.r=[];Sz.c=[];Sz.z=[];
            Sn1.idx=[];Sn1.r=[];Sn1.c=[];Sn1.z=[];
            Sp1.idx=[];Sp1.r=[];Sp1.c=[];Sp1.z=[];
            Sn2.idx=[];Sn2.r=[];Sn2.c=[];Sn2.z=[];
            Sp2.idx=[];Sp2.r=[];Sp2.c=[];Sp2.z=[];


            p2remove=obj.phi(obj.Lz.idx)>0.5;
            [obj.Lz,Sp1]=movePointsToList(obj.Lz,Sp1,p2remove);

            p2remove=obj.phi(obj.Lz.idx)<-0.5;
            [obj.Lz,Sn1]=movePointsToList(obj.Lz,Sn1,p2remove);


            if isempty(obj.Ln1.idx)
                L_neighIdx=[];
            else
                L_neighIdx=zeros(length(obj.Ln1.idx),size(obj.neighs,1));
                for i=1:size(obj.neighs,1)
                    L_neighIdx(:,i)=getNeighIdx(obj.neighs(i,:),...
                    obj.ImageSize,obj.Ln1.r,obj.Ln1.c,obj.Ln1.z);
                end
            end
            phiVals=obj.phi(L_neighIdx);
            phiVals(obj.label(L_neighIdx)<0)=-3;
            M=max(phiVals,[],2);
            isHasLNeigh=M>=-0.5;
            obj.phi(obj.Ln1.idx(isHasLNeigh))=M(isHasLNeigh)-1;
            [obj.Ln1,Sn2]=movePointsToList(obj.Ln1,Sn2,~isHasLNeigh);

            p2remove=obj.phi(obj.Ln1.idx)>=-0.5;
            [obj.Ln1,Sz]=movePointsToList(obj.Ln1,Sz,p2remove);

            p2remove=obj.phi(obj.Ln1.idx)<-1.5;
            [obj.Ln1,Sn2]=movePointsToList(obj.Ln1,Sn2,p2remove);


            if isempty(obj.Lp1.idx)
                L_neighIdx=[];
            else
                L_neighIdx=zeros(length(obj.Lp1.idx),size(obj.neighs,1));
                for i=1:size(obj.neighs,1)
                    L_neighIdx(:,i)=getNeighIdx(obj.neighs(i,:),...
                    obj.ImageSize,obj.Lp1.r,obj.Lp1.c,obj.Lp1.z);
                end
            end
            phiVals=obj.phi(L_neighIdx);
            phiVals(obj.label(L_neighIdx)>0)=3;
            M=min(phiVals,[],2);
            isHasLNeigh=M<=0.5;
            obj.phi(obj.Lp1.idx(isHasLNeigh))=M(isHasLNeigh)+1;
            [obj.Lp1,Sp2]=movePointsToList(obj.Lp1,Sp2,~isHasLNeigh);

            p2remove=obj.phi(obj.Lp1.idx)<=0.5;
            [obj.Lp1,Sz]=movePointsToList(obj.Lp1,Sz,p2remove);

            p2remove=obj.phi(obj.Lp1.idx)>1.5;
            [obj.Lp1,Sp2]=movePointsToList(obj.Lp1,Sp2,p2remove);


            if isempty(obj.Ln2.idx)
                L_neighIdx=[];
            else
                L_neighIdx=zeros(length(obj.Ln2.idx),size(obj.neighs,1));
                for i=1:size(obj.neighs,1)
                    L_neighIdx(:,i)=getNeighIdx(obj.neighs(i,:),...
                    obj.ImageSize,obj.Ln2.r,obj.Ln2.c,obj.Ln2.z);
                end
            end
            phiVals=obj.phi(L_neighIdx);
            phiVals(obj.label(L_neighIdx)<-1)=-3;
            M=max(phiVals,[],2);
            isHasLNeigh=M>=-1.5;
            obj.phi(obj.Ln2.idx(isHasLNeigh))=M(isHasLNeigh)-1;
            obj.label(obj.Ln2.idx(~isHasLNeigh))=-3;
            obj.phi(obj.Ln2.idx(~isHasLNeigh))=-3;
            obj.Ln2=removePointsFromList(obj.Ln2,~isHasLNeigh);

            p2remove=obj.phi(obj.Ln2.idx)>=-1.5;
            [obj.Ln2,Sn1]=movePointsToList(obj.Ln2,Sn1,p2remove);

            p2remove=obj.phi(obj.Ln2.idx)<-2.5;
            obj.label(obj.Ln2.idx(p2remove))=-3;
            obj.phi(obj.Ln2.idx(p2remove))=-3;
            obj.Ln2=removePointsFromList(obj.Ln2,p2remove);


            if isempty(obj.Lp2.idx)
                L_neighIdx=[];
            else
                L_neighIdx=zeros(length(obj.Lp2.idx),size(obj.neighs,1));
                for i=1:size(obj.neighs,1)
                    L_neighIdx(:,i)=getNeighIdx(obj.neighs(i,:),...
                    obj.ImageSize,obj.Lp2.r,obj.Lp2.c,obj.Lp2.z);
                end
            end
            phiVals=obj.phi(L_neighIdx);
            phiVals(obj.label(L_neighIdx)>1)=3;
            M=min(phiVals,[],2);
            isHasLNeigh=M<=1.5;
            obj.phi(obj.Lp2.idx(isHasLNeigh))=M(isHasLNeigh)+1;
            obj.label(obj.Lp2.idx(~isHasLNeigh))=3;
            obj.phi(obj.Lp2.idx(~isHasLNeigh))=3;
            obj.Lp2=removePointsFromList(obj.Lp2,~isHasLNeigh);

            p2remove=obj.phi(obj.Lp2.idx)<=1.5;
            [obj.Lp2,Sp1]=movePointsToList(obj.Lp2,Sp1,p2remove);

            p2remove=obj.phi(obj.Lp2.idx)>2.5;
            obj.label(obj.Lp2.idx(p2remove))=3;
            obj.phi(obj.Lp2.idx(p2remove))=3;
            obj.Lp2=removePointsFromList(obj.Lp2,p2remove);

        end

        function obj=movePointsIntoLevelSets(obj,Sz,Sn1,Sp1,Sn2,Sp2)

            import images.activecontour.internal.*;


            obj.label(Sz.idx)=0;
            [~,obj.Lz]=movePointsToList(Sz,obj.Lz,true(size(Sz.idx)));


            obj.label(Sn1.idx)=-1;
            n=length(Sn1.idx);
            if n<1
                L_neighIdx=[];
            else
                L_neighIdx=zeros(n*size(obj.neighs,1),1);
                for i=1:size(obj.neighs,1)
                    L_neighIdx(n*(i-1)+1:n*i)=getNeighIdx(...
                    obj.neighs(i,:),obj.ImageSize,Sn1.r,Sn1.c,Sn1.z);
                end
            end
            L_neighIdx=unique(L_neighIdx);
            isHasLNeigh=obj.phi(L_neighIdx)==-3;
            neighIdx=L_neighIdx(isHasLNeigh);
            origIdx=repmat(Sn1.idx,size(obj.neighs,1),1);
            origIdx=origIdx(isHasLNeigh);
            obj.phi(neighIdx)=obj.phi(origIdx)-1;
            Sn2=addNewPointsToList(Sn2,obj.ImageSize,neighIdx);

            [~,obj.Ln1]=movePointsToList(Sn1,obj.Ln1,true(size(Sn1.idx)));


            obj.label(Sp1.idx)=1;
            n=length(Sp1.idx);
            if n<1
                L_neighIdx=[];
            else
                L_neighIdx=zeros(n*size(obj.neighs,1),1);
                for i=1:size(obj.neighs,1)
                    L_neighIdx(n*(i-1)+1:n*i)=getNeighIdx(...
                    obj.neighs(i,:),obj.ImageSize,Sp1.r,Sp1.c,Sp1.z);
                end
            end
            L_neighIdx=unique(L_neighIdx);
            isHasLNeigh=obj.phi(L_neighIdx)==3;
            neighIdx=L_neighIdx(isHasLNeigh);
            origIdx=repmat(Sp1.idx,size(obj.neighs,1),1);
            origIdx=origIdx(isHasLNeigh);
            obj.phi(neighIdx)=obj.phi(origIdx)+1;
            Sp2=addNewPointsToList(Sp2,obj.ImageSize,neighIdx);

            [~,obj.Lp1]=movePointsToList(Sp1,obj.Lp1,true(size(Sp1.idx)));


            obj.label(Sn2.idx)=-2;
            [~,obj.Ln2]=movePointsToList(Sn2,obj.Ln2,true(size(Sn2.idx)));


            obj.label(Sp2.idx)=2;
            [~,obj.Lp2]=movePointsToList(Sp2,obj.Lp2,true(size(Sp2.idx)));

        end

    end

end




function[fromList,toList]=movePointsToList(fromList,toList,pnts2move)

    toList=copyPointsToList(fromList,toList,pnts2move);

    fromList=removePointsFromList(fromList,pnts2move);
end


function toList=copyPointsToList(fromList,toList,pnts2move)

    toList.idx=[toList.idx;fromList.idx(pnts2move)];
    toList.r=[toList.r;fromList.r(pnts2move)];
    toList.c=[toList.c;fromList.c(pnts2move)];
    toList.z=[toList.z;fromList.z(pnts2move)];
end


function fromList=removePointsFromList(fromList,pnts2remove)

    fromList.idx(pnts2remove)=[];fromList.r(pnts2remove)=[];
    fromList.c(pnts2remove)=[];fromList.z(pnts2remove)=[];
end


function pointList=addNewPointsToList(pointList,imgSize,idx)
    [r,c,z]=ind2sub(imgSize,idx);
    pointList.idx=[pointList.idx;idx];
    pointList.r=[pointList.r;r];
    pointList.c=[pointList.c;c];
    pointList.z=[pointList.z;z];
end

function D=neighD(A)
    D=A([2:end,end],:,:);
end

function U=neighU(A)
    U=A([1,1:end-1],:,:);
end

function L=neighL(A)
    L=A(:,[1,1:end-1],:);
end

function R=neighR(A)
    R=A(:,[2:end,end],:);
end

function F=neighF(A)
    F=A(:,:,[1,1:end-1]);
end

function B=neighB(A)
    B=A(:,:,[2:end,end]);
end

