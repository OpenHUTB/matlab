function[doaIndex]=checkdoa(obj)


    if strcmpi(class(obj),'conformalArray')

        if~iscell(obj.Element)
            error(message('antenna:antennaerrors:Invalidcellarray'));
        end

        if length(obj.Element)~=2
            error(message('antenna:antennaerrors:InvalidarrayInputDoa'));
        end


        ObjTx=obj.Element{1};
        [nT,~]=size(ObjTx.FeedLocation);
        if nT>1
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Array as transmitter'));
        end
        Feedloc=obj.FeedLocation;
        TxFeedloc=Feedloc(1,:);

        if TxFeedloc(3)<=0
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Transmitter below or in the z=0 plane'));
        end


        if isprop(ObjTx,'GroundPlaneLength')
            if isinf(ObjTx.GroundPlaneLength)
                error(message('antenna:antennaerrors:Unsupported',...
                'DoA','Transmitter with infinite ground'));
            end
            if isinf(ObjTx.GroundPlaneWidth)
                error(message('antenna:antennaerrors:Unsupported',...
                'DoA','Transmitter with infinite ground'));
            end
        elseif isprop(ObjTx,'GroundPlaneRadius')&&isinf(ObjTx.GroundPlaneRadius)
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Transmitter with infinite ground'));
        end


        RxCenter=obj.ElementPosition(2,:);
        RxCenterIndex=find(RxCenter);
        if RxCenterIndex~=0
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Receiving array centre other than origin'));
        end
    end


    if strcmpi(class(obj),'conformalArray')
        ObjRx=obj.Element{2};
        Feedloc=obj.FeedLocation;
        TrFeedloc=Feedloc(2:end,:);
    else
        ObjRx=obj.Element;
        TrFeedloc=ObjRx.FeedLocation;
    end



    [nR,~]=size(TrFeedloc);

    if nR==1
        error(message('antenna:antennaerrors:InvalidReceiverAntenna'));
    end



    if isa(ObjRx,'linearArray')
        doaIndex=0;
    elseif isa(ObjRx,'rectangularArray')
        doaIndex=1;
    else
        error(message('antenna:antennaerrors:InvalidArrayDoa'));
    end


    ObjRxElement=ObjRx.Element;
    [~,nRelem]=size(ObjRxElement);
    if nRelem~=1
        error(message('antenna:antennaerrors:Unsupported',...
        'DoA','Non-homogenous receiving array'));
    end


    if isprop(ObjRx,'GroundPlaneLength')
        if isinf(ObjRx.GroundPlaneLength)
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Receiver with infinite ground'));
        end
        if isinf(ObjRx.GroundPlaneWidth)
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Receiver with infinite ground'));
        end
    elseif isprop(ObjRx,'GroundPlaneRadius')&&isinf(ObjRx.GroundPlaneRadius)
        error(message('antenna:antennaerrors:Unsupported',...
        'DoA','Receiver with infinite ground'));
    end


    if strcmpi(class(ObjRx),'linearArray')

        if rem(nR,2)~=0
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Odd number of receiving antennas'));
        end


        ObjRxElementGap=ObjRx.ElementSpacing;
        [~,nRelemGap]=size(ObjRxElementGap);
        if nRelemGap~=1
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Non-uniform receiving array'));
        end
    elseif strcmpi(class(ObjRx),'rectangularArray')


        RxSize=ObjRx.Size;
        rowsize=RxSize(1);
        colsize=RxSize(2);

        if rem(rowsize,2)~=0
            error(message('antenna:antennaerrors:InvalidRowsizeDoa'));
        end
        if rem(colsize,2)~=0
            error(message('antenna:antennaerrors:InvalidColsizeDoa'));
        end


        ObjRxElementGapRow=ObjRx.RowSpacing;
        ObjRxElementGapCol=ObjRx.ColumnSpacing;
        [~,nRelemGapRow]=size(ObjRxElementGapRow);
        [~,nRelemGapCol]=size(ObjRxElementGapCol);
        if nRelemGapRow~=1||nRelemGapCol~=1
            error(message('antenna:antennaerrors:Unsupported',...
            'DoA','Non-uniform receiving array'));
        end
    end
end