


classdef TaperType

    enumeration
        None(1,'None',@getNoneTaper,@genCodeNone)
        Hamming(2,'Hamming',@getHammingTaper,@genCodeHamming)
        Chebyshev(3,'Chebyshev',@getChebyshevTaper,@genCodeChebyshev)
        Hann(4,'Hann',@getHannTaper,@genCodeHann)
        Kaiser(5,'Kaiser',@getKaiserTaper,@genCodeKaiser)
        Taylor(6,'Taylor',@getTaylorTaper,@genCodeTaylor)
        Custom(7,'Custom',@getCustomTaper,@genCodeCustom)

    end

    properties
ID
Name
TaperGetCallback
GenCodeCallback
    end


    methods(Static)
        function N=names
            N=arrayfun(@(a)a.Name,enumeration('phased.apps.internal.SensorArrayViewer.TaperType'),'UniformOutput',false);
        end

        function tt=getTaperAtPos(pos)

            E=enumeration('phased.apps.internal.SensorArrayViewer.TaperType');

            ids=arrayfun(@(a)a.ID,E);

            [~,I]=sortrows(ids);

            finals=arrayfun(@(a)ismember(a,pos),I);

            tt=E(I(finals));
        end
    end

    methods

        function obj=TaperType(id,tag,cb,gccb)
            obj.ID=id;
            obj.Name=getString(message(['phased:apps:arrayapp:',tag]));
            obj.TaperGetCallback=cb;
            obj.GenCodeCallback=gccb;
        end

        function t=computeTaper(obj,numElements,...
            sidelobeAttenuation,...
            nbar,...
            beta,...
            customTaper)

            t=obj.TaperGetCallback(obj,numElements,...
            sidelobeAttenuation,...
            nbar,...
            beta,...
            customTaper);
        end

        function genCode(obj,mcode,wind,...
            numElements,...
            sidelobeAttenuation,...
            nbar,...
            beta,...
            customTaper,...
            customTaperString)

            obj.GenCodeCallback(obj,mcode,wind,...
            numElements,...
            sidelobeAttenuation,...
            nbar,...
            beta,...
            customTaper,...
            customTaperString);
        end

    end

    methods


        function taper=getNoneTaper(~,numElements,~,~,~,~)
            taper=ones(1,numElements);
        end

        function genCodeNone(~,mcode,wind,numElements,~,~,~,~,~)
            mcode.addcr([wind,' = ones(1,',num2str(numElements),');']);
        end


        function taper=getHammingTaper(~,numElements,~,~,~,~)
            taper=hamming(numElements)';
        end

        function genCodeHamming(~,mcode,wind,numElements,~,~,~,~,~)
            mcode.addcr([wind,' = hamming(',num2str(numElements),')'';']);
        end



        function taper=getChebyshevTaper(~,numElements,sidelobeAttenuation,~,~,~)
            taper=chebwin(numElements,sidelobeAttenuation)';
        end

        function genCodeChebyshev(~,mcode,wind,numElements,sidelobeAttenuation,~,~,~,~)
            mcode.addcr(['sll = ',num2str(sidelobeAttenuation),';']);
            mcode.addcr([wind,' = chebwin(',num2str(numElements),', sll)'';']);
        end


        function taper=getHannTaper(~,numElements,~,~,~,~)
            taper=hann(numElements)';
        end

        function genCodeHann(~,mcode,wind,numElements,~,~,~,~,~)
            mcode.addcr([wind,' = hann(',num2str(numElements),')'';']);
        end


        function taper=getKaiserTaper(~,numElements,~,beta,~,~)
            taper=kaiser(numElements,beta)';
        end

        function genCodeKaiser(~,mcode,wind,numElements,~,beta,~,~,~)
            mcode.addcr(['beta = ',num2str(beta),';']);
            mcode.addcr([wind,' = kaiser(',num2str(numElements),', beta)'';']);
        end


        function taper=getTaylorTaper(~,numElements,sidelobeAttenuation,~,nbar,~)
            taper=taylorwin(numElements,nbar,-sidelobeAttenuation)';
        end

        function genCodeTaylor(~,mcode,wind,numElements,sidelobeAttenuation,~,nbar,~,~)
            mcode.addcr(['sll = -',num2str(sidelobeAttenuation),';']);
            mcode.addcr(['nbar = ',num2str(nbar),';']);
            mcode.addcr([wind,' = taylorwin(',num2str(numElements),', nbar, sll)'';']);
        end


        function taper=getCustomTaper(~,numElements,~,~,~,customTaper)
            if iscolumn(customTaper)
                customTaper=customTaper';
            end
            taper=customTaper;

            if isscalar(taper)
                taper=repmat(taper,1,numElements);
            end
        end

        function genCodeCustom(~,mcode,wind,numElements,~,~,~,customTaper,customTaperString)
            if iscolumn(customTaper)
                customTaper=customTaper';
                customTaperString=[customTaperString,'.'''];
            end

            if isscalar(customTaper)
                if customTaper==1
                    str='';
                else
                    str=[num2str(customTaper),'*'];
                end
                mcode.addcr([wind,' = ',str,'ones(1,',num2str(numElements),');']);
            else
                mcode.addcr([wind,' = ',customTaperString,';']);
            end
        end

    end

    methods
        function[taper,w]=computeWindow(obj,curAT)

            nE=curAT.getArraySize();

            F=curAT.SignalFreqs;
            SA=curAT.SteeringAngles;
            PSB=curAT.PhaseShiftBits;

            if(curAT.SteeringIsOn)
                NumSA=size(SA,2);
                NumF=length(F);
                NumPSB=length(PSB);


                [SA,F,PSB]=phased.apps.internal.SensorArrayViewer.makeEqualLength(SA,F,PSB,NumSA,NumF,NumPSB);


                [NumRefPlots,RefPlotAtEndFlag]=computeNumReferencePlots(PSB,NumSA,NumF,NumPSB);

                if NumRefPlots>0
                    SV_ref=phased.SteeringVector('SensorArray',curAT.ArrayObj,...
                    'PropagationSpeed',curAT.PropSpeed,...
                    'NumPhaseShifterBits',0);
                end

                w=zeros(nE,length(F)+NumRefPlots);
                w_indx=1;

                if(NumPSB==1)
                    SV=phased.SteeringVector('SensorArray',curAT.ArrayObj,...
                    'PropagationSpeed',curAT.PropSpeed,...
                    'NumPhaseShifterBits',curAT.PhaseShiftBits);
                    for idx=1:length(F)
                        w(:,w_indx)=step(SV,F(idx),SA(:,idx));
                        w_indx=w_indx+1;

                        if PSB(idx)>0
                            w(:,w_indx)=step(SV_ref,F(idx),SA(:,idx));
                            w_indx=w_indx+1;
                        end
                    end
                else
                    for idx=1:length(F)
                        SV=phased.SteeringVector('SensorArray',curAT.ArrayObj,...
                        'PropagationSpeed',curAT.PropSpeed,...
                        'NumPhaseShifterBits',PSB(idx));
                        w(:,w_indx)=step(SV,F(idx),SA(:,idx));
                        w_indx=w_indx+1;

                        if PSB(idx)>0&&(NumRefPlots>0)&&((~RefPlotAtEndFlag)||((RefPlotAtEndFlag)&&(idx==length(F))))
                            w(:,w_indx)=step(SV_ref,F(idx),SA(:,idx));
                            w_indx=w_indx+1;
                        end
                    end
                end

            else
                w=ones(nE,length(F));

            end

            if isa(curAT,'phased.apps.internal.SensorArrayViewer.ATUniformLinear')

                taper=obj.computeTaper(nE,curAT.SidelobeAttenuation,...
                curAT.Beta,curAT.Nbar,curAT.CustomTaper);

            elseif isa(curAT,'phased.apps.internal.SensorArrayViewer.ATUniformRectangular')
                RectSize=curAT.Size;
                if(curAT.isTaperRowCol)

                    rwind=obj.computeTaper(RectSize(2),curAT.RowSidelobeAttenuation,...
                    curAT.RowBeta,curAT.RowNbar,curAT.RowCustomTaper);
                    rwind=repmat(rwind,RectSize(1),1);




                    colTaperType=phased.apps.internal.SensorArrayViewer.TaperType.getTaperAtPos(curAT.ColTaperTypeIndex);
                    cwind=colTaperType.computeTaper(RectSize(1),curAT.ColSidelobeAttenuation,...
                    curAT.ColBeta,curAT.ColNbar,curAT.ColCustomTaper);
                    cwind=repmat(cwind.',1,RectSize(2));
                    taper=rwind.*cwind;
                else
                    taper=curAT.CustomTaper;
                    if isscalar(taper)
                        taper=repmat(taper,RectSize(1),RectSize(2));
                    end
                end
            else


                taper=obj.computeTaper(nE,0,0,0,curAT.CustomTaper);
            end
        end
    end

end




















function[NumRefPlots,RefPlotAtEndFlag]=computeNumReferencePlots(PSB,NumSA,NumF,NumPSB)

    idx_forRefPlot=find(PSB);
    RefPlotAtEndFlag=0;
    if(NumF==1)&&(NumSA==1)
        if(length(idx_forRefPlot)==NumPSB)
            NumRefPlots=1;
            RefPlotAtEndFlag=1;
        else
            NumRefPlots=0;
        end
    else
        NumRefPlots=length(idx_forRefPlot);
    end
end

