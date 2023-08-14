



function[lctSpecInfo,lctObj]=extract(lctObj,type)


    narginchk(1,2);
    nargoutchk(0,2);


    if numel(lctObj)>1||~(isstruct(lctObj)||isa(lctObj,'legacycode.LCT'))
        error(message('Simulink:tools:LCTErrorFirstFcnArgumentMustBeScalarStruct'));
    end


    if nargin<2
        type='other';
    else
        type=lower(type);
    end


    if isa(lctObj,'legacycode.LCT')
        lctSpec=lctObj;
    else
        lctSpec=legacycode.LCT(lctObj);
        lctObj=legacycode.LCT.getSpecStruct(true,lctSpec);
    end


    lctSpecInfo=legacycode.lct.LCTSpecInfo();
    lctSpecInfo.Specs=lctSpec;


    if lctSpecInfo.Specs.Options.convertNDArrayToRowMajor&&lctSpecInfo.Specs.Options.singleCPPMexFile
        error(message('Simulink:tools:LCTSFcnCodeAPIErrorNDArrayNotSupported'));
    end

    try


        lctSpecInfo.extractAllInfo(type);

    catch Me

        lctErrIdRadix=legacycode.lct.spec.Common.LctErrIdRadix;

        if strncmp(lctErrIdRadix,Me.identifier,numel(lctErrIdRadix))


            throw(Me);
        else

            rethrow(Me);
        end
    end


