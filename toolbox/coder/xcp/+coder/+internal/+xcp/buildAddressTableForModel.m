function buildAddressTableForModel(buildInfo,buildDir,modelName)





    ?coder.internal.connectivity.XcpTargetConnection;
    if~slfeature('ExtModeXCPImageType')
        return;
    end

    targetLang=get_param(modelName,'TargetLang');

    filename='xcp_fill_addr_table';

    if strcmp(targetLang,'C')
        filename=[filename,'.c'];
        isCppClass=false;
    elseif strcmp(targetLang,'C++')
        filename=[filename,'.cpp'];
        codeInterfacePackaging=get_param(modelName,'CodeInterfacePackaging');
        isCppClass=strcmp(codeInterfacePackaging,'C++ class');
    else
        assert(false,['Invalid target lang ',targetLang]);
    end

    codeDescriptor=coder.internal.getCodeDescriptorInternal(buildDir,247362);

    if isCppClass



        topModelObjectImplementation=...
        codeDescriptor.getFullComponentInterface.InternalData(1).Implementation;
        assert(...
        isa(topModelObjectImplementation,'coder.descriptor.Variable')...
        &&isa(topModelObjectImplementation.Type,'coder.descriptor.types.Class'),...
        'invalid model object');

        topModelObj=topModelObjectImplementation.assumeOwnershipAndGetExpression();
        topModelType=topModelObjectImplementation.Type.Identifier;
        symbolPrefix=[topModelObj,'.'];


        topModelObjDeclaration=['extern ',topModelType,' ',topModelObj,';'];
    else
        symbolPrefix='';
        topModelObjDeclaration='';
    end

    handle=get_param(modelName,'Handle');
    mf0Model=coder.xcp.trig.classic.getModel(handle);

    singleInstModels=coder.internal.xcp.fillAddressTable(...
    codeDescriptor,mf0Model,isCppClass,symbolPrefix);

    addressTable=coder.xcp.addresstable.AddressTable.getTable(mf0Model);
    signalsToAdd=assignAddresses(addressTable);

    xcpDirInBuildDir=fullfile(buildDir,'xcp');
    if isfolder(xcpDirInBuildDir)
        slprivate('removeDir',xcpDirInBuildDir);
    end
    mkdir(xcpDirInBuildDir);



    serializer=mf.zero.io.JSONSerializer;
    serializer.serializeToFile(addressTable,fullfile(xcpDirInBuildDir,'addr_table.json'));

    if numel(signalsToAdd)==0

        return;
    end


    writeImplFile(...
    fullfile(xcpDirInBuildDir,filename),...
    singleInstModels,...
    signalsToAdd,...
    addressTable.BitsForIndex,...
    topModelObjDeclaration);

    srcFiles={filename};
    srcFilePaths={xcpDirInBuildDir};
    buildInfo.addSourceFiles(srcFiles,srcFilePaths,'EXT_MODE');

    defines={'-DXCP_CUSTOM_ADDRESS_TRANSLATION'};

    buildInfo.addDefines(defines,coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
end

function address=indexToAddres(idx,bitsForOffset)
    address=...
...
    uint64(bitshift(1,39))+...
...
    uint64(bitshift(idx,bitsForOffset));
    assert(address<bitshift(1,40)-1);
end

function signalsToAdd=assignAddresses(addressTable)


    signals=addressTable.Signals.toArray();
    signalsToAdd=[];
    tableIdx=0;
    for i=1:numel(signals)
        sig=signals(i);

        if tableIdx>=addressTable.maxNumEntries()
            sig.UnsupportedReason=coder.xcp.addresstable.UnsupportedReason.TooMany;
        end

        if sig.isSupported()
            sig.IndexInTable=uint64(tableIdx);
            sig.Address=indexToAddres(tableIdx,addressTable.bitsForOffset());
            signalsToAdd=[signalsToAdd,sig];%#ok<AGROW>
            tableIdx=tableIdx+1;
        end

    end
end

function writeImplFile(filename,singleInstMdl,signals,bitsIndex,topMdlObjDeclaration)


    writer=rtw.connectivity.CodeWriter.create(...
    language='C',...
    filename=filename,...
    callCBeautifier=true);




    for i=numel(singleInstMdl):-1:1
        writer.wLine(['#include "',singleInstMdl{i},'.h"']);
    end


    if~isempty(topMdlObjDeclaration)
        writer.wLine(topMdlObjDeclaration);
        writer.wNewLine;
    end




    writer.wLine('#ifdef __cplusplus');
    writer.wLine('extern "C" {');
    writer.wLine('#endif');

    writer.wLine('#include "xcp_common.h"');

    writeTableAccessFunction(writer,numel(signals));

    writeTableInit(writer,signals);

    writeXcpCustomRead(writer,bitsIndex);

    writer.wLine('#ifdef __cplusplus');
    writer.wLine('}');
    writer.wLine('#endif');

    writer.close();

end

function writeTableAccessFunction(writer,tableDim)


    writer.wBlockStart('static void const** getTable(void)');
    writer.wLine(['static void const* table[',num2str(tableDim),'];']);
    writer.wLine('return table;');
    writer.wBlockEnd();

end

function writeTableInit(writer,signals)


    writer.wBlockStart('void xcpInitCustomAddressGet(void)');
    writer.wLine('void const** table = getTable();');
    for i=1:numel(signals)
        sig=signals(i);
        writer.wLine(['table[',num2str(sig.IndexInTable),'] = ',sig.AddressExpression,';']);
    end
    writer.wBlockEnd();

end

function writeXcpCustomRead(writer,bitsForIndex)




    assert(bitsForIndex>=7||bitsForIndex<=32,...
    "Invalid number of bits for indexing the address table.");



    writer.wLine('#define EXT_MSB_MASK 0x80');

    writer.wLine('#define EXT_REM_MSB_MASK 0x7F');

    writer.wBlockStart('uint8_T const* xcpCustomAddressGetRead(uint8_T extension, uint32_T address)');
    writer.wLine('uint8_T const* addr;');
    writer.wBlockStart('if (extension & EXT_MSB_MASK)');

    bitsForIndexFromAddress=bitsForIndex-7;
    writer.wLine('void const** table = getTable();');
    writer.wLine('uint32_T index = extension & EXT_REM_MSB_MASK;');
    writer.wLine('uint32_T offset = address;');
    if bitsForIndexFromAddress>0
        bitsForOffset=32-bitsForIndexFromAddress;

        writer.wLine('index = index << %d;',bitsForIndexFromAddress);
        writer.wLine('index += address >> %d;',bitsForOffset);

        mask=bitshift(1,bitsForOffset)-1;
        writer.wLine(['offset = offset & 0x',dec2hex(mask),';']);
    end

    writer.wLine(['#if (defined(XCP_ADDRESS_GRANULARITY) && '...
    ,'defined(XCP_HARDWARE_ADDRESS_GRANULARITY)) && '...
    ,'(XCP_ADDRESS_GRANULARITY != XCP_HARDWARE_ADDRESS_GRANULARITY)']);
    writer.wLine(['#if (XCP_ADDRESS_GRANULARITY != ADDRESS_GRANULARITY_BYTE || '...
    ,'XCP_HARDWARE_ADDRESS_GRANULARITY != ADDRESS_GRANULARITY_WORD)']);
    writer.wLine('#error "Unsupported  granularity emulation mode"');
    writer.wLine('#endif');
    writer.wLine('offset >>= 1;');
    writer.wLine('#endif');


    writer.wLine('addr = (uint8_T const*)table[index];');
    writer.wLine('addr += offset;');
    writer.wBlockEnd()
    writer.wBlockStart('else');

    writer.wLine('addr = XCP_ADDRESS_GET(extension, address);');
    writer.wBlockEnd();
    writer.wLine('return addr;')
    writer.wBlockEnd();

end


