classdef MemoryMap<matlab.mixin.Copyable

    properties(SetObservable)
        isMapValid=false;
controllerInfo
        isAutoMap=true;
        isFixedMemMap=false;
map
    end


    properties(Access=private)

    end


    methods
        function[isValid,errStr]=checkMemoryMap(obj,varargin)
            isValid=true;
            errStr='';

            try
                obj.isMapValid=true;
                obj.checkBaseAddressAlignment();

                obj.checkAgainstControllerBounds('memPS');
                obj.checkAgainstControllerBounds('memPL');
                obj.checkAgainstControllerBounds('register');

                obj.checkForMemoryOverlap('memPS');
                obj.checkForMemoryOverlap('memPL');
                obj.checkForMemoryOverlap('register');

                obj.checkRegisterOffsetAlignment();
                obj.checkForRegisterOverlap();

            catch ME
                obj.isMapValid=false;

                isValid=false;
                errStr=ME.message();

            end
        end
    end
    methods(Static)
        function valid=checkOffsetFormat(str)
            valid=l_checkHexAddressFormat(str,4);
        end
        function valid=checkAddressFormat(str)
            valid=l_checkHexAddressFormat(str,8);
        end
    end
    methods(Access=private)

        function checkBaseAddressAlignment(obj)
            for i=1:length(obj.map)
                switch obj.map(i).type
                case{soc.memmap.MemUtil.strDevUser,soc.memmap.MemUtil.strDevImplicit}
                    baseAddr=obj.map(i).baseAddr;
                    range=obj.map(i).range;
                    switch[range{:}]
                    case '16K'
                        if~strcmpi(baseAddr(end-3:end),{'0000','4000','8000','C000'})
                            goodAddr={[baseAddr(1:end-4),'0000'],[baseAddr(1:end-4),'4000'],[baseAddr(1:end-4),'8000'],[baseAddr(1:end-4),'C000']};
                            errMsg=message('soc:memmap:BadIPAddressAlignment',obj.map(i).name,baseAddr,sprintf('%s ',goodAddr{:}),'16');
                            error(errMsg);
                        end
                    case '32K'
                        if~strcmpi(baseAddr(end-3:end),{'0000','8000'})
                            goodAddr={[baseAddr(1:end-4),'0000'],[baseAddr(1:end-4),'8000']};
                            errMsg=message('soc:memmap:BadIPAddressAlignment',obj.map(i).name,baseAddr,sprintf('%s ',goodAddr{:}),'32');
                            error(errMsg);
                        end
                    case '64K'
                        if~strcmpi(baseAddr(end-3:end),{'0000'})
                            goodAddr={[baseAddr(1:end-4),'0000']};
                            errMsg=message('soc:memmap:BadIPAddressAlignment',obj.map(i).name,baseAddr,sprintf('%s ',goodAddr{:}),'64');
                            error(errMsg);
                        end
                    case '128K'
                        if~strcmpi(baseAddr(end-4:end),{'00000','20000','40000','60000','80000','A0000','C0000','E0000',})
                            goodAddr={[baseAddr(1:end-5),'00000'],[baseAddr(1:end-5),'20000'],[baseAddr(1:end-5),'40000'],[baseAddr(1:end-5),'60000'],...
                            [baseAddr(1:end-5),'80000'],[baseAddr(1:end-5),'A0000'],[baseAddr(1:end-5),'C0000'],[baseAddr(1:end-5),'E0000'],};
                            errMsg=message('soc:memmap:BadIPAddressAlignment',obj.map(i).name,baseAddr,sprintf('%s ',goodAddr{:}),'128');
                            error(errMsg);
                        end
                    case '256K'
                        if~strcmpi(baseAddr(end-4:end),{'00000','40000','80000','C0000'})
                            goodAddr={[baseAddr(1:end-5),'00000'],[baseAddr(1:end-5),'40000'],[baseAddr(1:end-5),'80000'],[baseAddr(1:end-5),'C0000']};
                            errMsg=message('soc:memmap:BadIPAddressAlignment',obj.map(i).name,baseAddr,sprintf('%s ',goodAddr{:}),'256');
                            error(errMsg);
                        end
                    case '512K'
                        if~strcmpi(baseAddr(end-4:end),{'00000','80000'})
                            goodAddr={[baseAddr(1:end-5),'00000'],[baseAddr(1:end-5),'80000']};
                            errMsg=message('soc:memmap:BadIPAddressAlignment',obj.map(i).name,baseAddr,sprintf('%s ',goodAddr{:}),'512');
                            error(errMsg);
                        end
                    otherwise

                    end
                case{soc.memmap.MemUtil.strDevPSMemory,soc.memmap.MemUtil.strDevPLMemory}

                    baseAddr=obj.map(i).baseAddr;
                    if~strcmp(baseAddr(end-2:end),'000')
                        goodAddr=[baseAddr(1:end-3),'000'];
                        error(message('soc:memmap:BadIPAddressAlignment',obj.map(i).name,baseAddr,goodAddr,'4'));
                    end
                otherwise

                end
            end
        end
        function checkRegisterOffsetAlignment(obj)
            for i=1:length(obj.map)
                if strcmp(obj.map(i).type,soc.memmap.MemUtil.strDevUser)
                    regs=findobj(obj.map(i).regs,'reserved',false);
                    if~isempty(regs)
                        badItems='';
                        regNotAligned=false;
                        for jj=1:numel(regs)
                            regVecLen=str2double(regs(jj).vectorlength);
                            regAlignment=l_getVecBlockSize(regVecLen)*obj.controllerInfo.regSize;
                            regOffset=hex2dec(regs(jj).offset);
                            if regOffset~=ceil(regOffset/regAlignment)*regAlignment
                                regNotAligned=true;
                                regName=[regs(jj).blkname,'/',regs(jj).register];
                                msg=message('soc:memmap:RegisterOffsetUnaligned',regName,regs(jj).offset,l_decAsHex(regAlignment));
                                badItems=sprintf('%s%s',badItems,msg.getString());
                            end
                        end
                        if regNotAligned
                            errMsg=message('soc:memmap:RegisterOffsetUnalignedConcated',badItems);
                            error(errMsg);
                        end
                    end
                end
            end
        end

        function checkAgainstControllerBounds(obj,RegionType)

            switch RegionType
            case{'memPS'}
                RegionBaseAddrStr=obj.controllerInfo.memPSBaseAddr;
                RegionAddrRangeStr=obj.controllerInfo.memPSRange;
                Types={'PS Memory Region'};
            case{'memPL'}
                RegionBaseAddrStr=obj.controllerInfo.memPLBaseAddr;
                RegionAddrRangeStr=obj.controllerInfo.memPLRange;
                Types={'PL Memory Region'};
            case{'register'}
                RegionBaseAddrStr=obj.controllerInfo.regBaseAddr;
                RegionAddrRangeStr=obj.controllerInfo.regAddrRange;
                Types={'User Component','Implicit Component'};
            end

            found=arrayfun(@(x)(any(strcmp(x.type,Types))),obj.map);
            if~any(found)
                return;
            end

            list=obj.map(found);
            rangeList=obj.getMemoryRangeList(list);


            RegionBaseAddr=l_hex2decAddr(RegionBaseAddrStr);
            RegionEndAddr=l_hex2decAddr(RegionBaseAddrStr)+l_str2decRange(RegionAddrRangeStr);

            BaseAddr=cell2mat(rangeList(:,1));
            EndAddr=cell2mat(rangeList(:,2));

            badStartAddrs=(BaseAddr<RegionBaseAddr);
            badEndAddrs=(EndAddr>RegionEndAddr-1);
            badBounds=badStartAddrs|badEndAddrs;

            if any(badBounds)
                badBounds=rangeList(badBounds,:);
                badItems='';
                for i=1:size(badBounds,1)
                    msg=message('soc:memmap:MemoryAreaBoundsInfo',...
                    badBounds{i,3},l_dec2hexAddr(badBounds{i,1}),l_dec2hexAddr(badBounds{i,2}));
                    badItems=sprintf('%s%s',badItems,msg.getString());
                end
                errMsg=message('soc:memmap:MemoryAreaShouldBeInsideBoundsConcated',...
                RegionBaseAddrStr,sprintf('%s %sB',RegionAddrRangeStr{:}),badItems);
                error(errMsg);
            end
        end

        function checkForMemoryOverlap(obj,RegionType)

            switch RegionType
            case{'memPS'}
                Types={'PS Memory Region'};
            case{'memPL'}
                Types={'PL Memory Region'};
            case{'register'}
                Types={'User Component','Implicit Component'};
            end

            found=arrayfun(@(x)(any(strcmp(x.type,Types))),obj.map);
            list=obj.map(found);
            if numel(list)<2
                return;
            end
            rangeList=obj.getMemoryRangeList(list);

            sortedRangeList=sortrows(rangeList);
            se=cell2mat(sortedRangeList(:,[1,2]));
            overlaps=((se(2:end,1)-se(1:end-1,2))<=0);
            overlaps=[false;overlaps];
            if any(overlaps)
                badItems='';
                for i=1:size(sortedRangeList,1)
                    if overlaps(i)
                        msg=message('soc:memmap:MemoryAreaOverlap',...
                        sortedRangeList{i,3},l_dec2hexAddr(sortedRangeList{i,1}),l_dec2hexAddr(sortedRangeList{i,2}),...
                        sortedRangeList{i-1,3},l_dec2hexAddr(sortedRangeList{i-1,1}),l_dec2hexAddr(sortedRangeList{i-1,2})...
                        );
                        badItems=sprintf('%s\n%s',badItems,msg.getString());
                    end
                end
                errMsg=message('soc:memmap:MemoryAreaOverlapConcated',badItems);
                error(errMsg);
            end
        end
        function checkForRegisterOverlap(obj)
            uc=findobj(obj.map,'type','User Component');
            for ii=1:length(uc)
                regs=uc(ii).regs;
                if~isempty(regs)
                    rangeList=obj.getRegisterRangeList(uc(ii).regs);
                    sortedRangeList=sortrows(rangeList);
                    se=cell2mat(sortedRangeList(:,[1,2]));
                    overlaps=((se(2:end,1)-se(1:end-1,2))<=0);
                    overlaps=[false;overlaps];%#ok<AGROW> % the first region cannot be in violation
                    if any(overlaps)
                        badItems='';
                        for jj=1:size(sortedRangeList,1)
                            if overlaps(jj)
                                msg=message('soc:memmap:RegisterOverlap',...
                                sortedRangeList{jj,3},l_decAsHex(sortedRangeList{jj,1}),l_decAsHex(sortedRangeList{jj,2}),...
                                sortedRangeList{jj-1,3},l_decAsHex(sortedRangeList{jj-1,1}),l_decAsHex(sortedRangeList{jj-1,2})...
                                );
                                badItems=sprintf('%s\n%s',badItems,msg.getString());
                            end
                        end
                        errMsg=message('soc:memmap:RegisterOverlapConcated',badItems);
                        error(errMsg);
                    end
                end
            end
        end

        function rangeList=getMemoryRangeList(~,list)
            rangeLength=length(list);
            rangeList=cell([rangeLength,3]);
            for i=1:rangeLength
                ast=l_hex2decAddr(list(i).baseAddr);
                asi=l_str2decRange(list(i).range);
                ase=ast+asi-1;
                asn=list(i).name;

                rangeList(i,:)={ast,ase,asn};
            end
        end


        function rangeList=getRegisterRangeList(obj,list)
            rangeLength=length(list);
            rangeList=cell([rangeLength,3]);
            for i=1:rangeLength

                if list(i).reserved
                    ast=0;
                    ase=255;
                else
                    ast=hex2dec(list(i).offset);
                    asi=eval(list(i).vectorlength);
                    if asi==1
                        ase=ast+obj.controllerInfo.regSize-1;
                    else
                        ase=ast+(pow2(ceil(log2(asi)))+1)*obj.controllerInfo.regSize-1;
                    end
                end
                asn=[list(i).blkname,'/',list(i).register];
                rangeList(i,:)={ast,ase,asn};
            end
        end
    end
end

function addrBlockSize=l_getVecBlockSize(length)
    addrBlockSize=2^(ceil(log2(length)));
end


function valid=l_checkHexAddressFormat(str,width)
    totalChars=width+2;
    if(length(str)==totalChars&&str(1)=='0'&&str(2)=='x')
        extrStr=str(3:end);
        if(length(regexp(extrStr,'[0-9a-fA-F]'))==width)
            valid=true;
        else
            valid=false;
        end
    else
        valid=false;
    end
    if~valid
        errMsg=message('soc:memmap:BadAddressFormat',num2str(width));
        errordlg(errMsg.getString(),'Memory Map Error','modal');
    end
end

function hexStr=l_decAsHex(decNum)
    hexStr=['0x',dec2hex(decNum)];
end

function hexAddr=l_dec2hexAddr(decAddr)
    hexAddr=['0x',dec2hex(decAddr,8)];
end

function decAddr=l_hex2decAddr(hexAddr)
    decAddr=uint64(hex2dec(hexAddr));
end

function decRange=l_str2decRange(strRange)
    switch strRange{2}
    case ''
        mult=uint64(1);
    case 'K'
        mult=uint64(1024);
    case 'M'
        mult=uint64(1024*1024);
    case 'G'
        mult=uint64(1024*1024*1024);
    case 'T'
        mult=uint64(1024*1024*1024*1024);
    otherwise
        mult=uint64(1);
    end
    decRange=uint64(str2double(strRange{1})*mult);
end
