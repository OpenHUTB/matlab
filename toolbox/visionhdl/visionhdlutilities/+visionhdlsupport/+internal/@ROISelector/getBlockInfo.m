function blockInfo=getBlockInfo(this,hC)














    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;

        blockInfo.VerticalReuse=sysObjHandle.VerticalReuse;

        blockInfo.Regions=sysObjHandle.Regions;

        if blockInfo.VerticalReuse
            regionsProp=sysObjHandle.Regions;
            [reg,nVtiles,tableDatavTop,tableDatavBottom,uniformvTop]=sortRegions(regionsProp);
            blockInfo.Regions=reg;
            blockInfo.RegionsSource=0;
            blockInfo.NumberOfRegions=size(blockInfo.Regions,1);
            blockInfo.NumVTiles=nVtiles;
            blockInfo.TableDatavTop=tableDatavTop;
            blockInfo.TableDatavBottom=tableDatavBottom;
            blockInfo.uniformvTop=uniformvTop;
        else


            if strcmp(sysObjHandle.RegionsSource,'Input Port')
                blockInfo.RegionsSource=1;
                blockInfo.NumberOfRegions=sysObjHandle.NumberOfRegions;
            else
                blockInfo.RegionsSource=0;
                blockInfo.NumberOfRegions=size(blockInfo.Regions,1);
            end
        end
    else
        bfp=hC.Simulinkhandle;

        blockInfo.VerticalReuse=strcmp(get_param(bfp,'VerticalReuse'),'on');


        if blockInfo.VerticalReuse

            regionsProp=this.hdlslResolve('Regions',bfp);

            [reg,nVtiles,tableDatavTop,tableDatavBottom,uniformvTop]=sortRegions(regionsProp);
            blockInfo.Regions=reg;
            blockInfo.RegionsSource=0;
            blockInfo.NumberOfRegions=size(blockInfo.Regions,1);
            blockInfo.NumVTiles=nVtiles;
            blockInfo.TableDatavTop=tableDatavTop;
            blockInfo.TableDatavBottom=tableDatavBottom;
            blockInfo.uniformvTop=uniformvTop;
        else
            if strcmpi(get_param(bfp,'RegionsSource'),'Input Port')
                blockInfo.RegionsSource=1;
                blockInfo.Regions=0;
                blockInfo.NumberOfRegions=this.hdlslResolve('NumberOfRegions',bfp);
            else
                blockInfo.RegionsSource=0;
                blockInfo.Regions=this.hdlslResolve('Regions',bfp);
                blockInfo.NumberOfRegions=size(blockInfo.Regions,1);
            end
        end
    end
end



function[sRegions,numVtiles,tabledatavTop,tabledatavBottom,uniformvTop]=sortRegions(Regions)
    regionsdimension=size(Regions);
    regions=zeros(regionsdimension(1),regionsdimension(2));

    sortedVerRegions=sortrows(Regions,2);

    minVPos=min(sortedVerRegions(:,2));
    minHPos=min(sortedVerRegions(:,1));

    numHtiles=sum(sortedVerRegions(:,2)==minVPos);
    numVtiles=sum(sortedVerRegions(:,1)==minHPos);
    for regIdx=1:numHtiles:regionsdimension(1)
        if regIdx+numHtiles-1<=regionsdimension(1)

            regions(regIdx:regIdx+numHtiles-1,:)=sortrows(sortedVerRegions(regIdx:regIdx+numHtiles-1,:),1);
        end
    end

    sRegions=regions(1:numHtiles,:);

    wl=ceil(log2(numVtiles+1));
    tabledatavTop=zeros((2^wl),1);
    tabledatavBottom=zeros((2^wl),1);
    tIdx=2;
    for regIdx=1:numHtiles:regionsdimension(1)-numHtiles+1
        if regIdx==1
            tabledatavTop(tIdx)=regions(regIdx,2);
        else
            regvEndPrev=regions(regIdx-numHtiles,2)+regions(regIdx-numHtiles,4);
            if regvEndPrev~=regions(regIdx,2)
                offset=regions(regIdx,2)-regvEndPrev+1;
                tabledatavTop(tIdx)=offset;
            else
                tabledatavTop(tIdx)=1;
            end
        end
        tabledatavBottom(tIdx)=tabledatavTop(tIdx)+regions(regIdx,4)-1;
        tIdx=tIdx+1;
    end
    uniformvTop=true;

    for tIdx=2:numVtiles
        if tabledatavTop(tIdx)==tabledatavTop(tIdx+1)
            uniformvTop=true;
        else
            uniformvTop=false;
            break;
        end
    end

    maxvTop=max(tabledatavTop);
    addrWLvTop=max(1,ceil(log2(maxvTop+1)));
    tabledatavTop=fi(tabledatavTop,0,addrWLvTop,0);
    maxvBottom=max(tabledatavBottom);
    addrWLvBottom=max(1,ceil(log2(maxvBottom+1)));
    tabledatavBottom=fi(tabledatavBottom,0,addrWLvBottom,0);
end


