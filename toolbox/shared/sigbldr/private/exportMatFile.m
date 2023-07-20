function varargout=exportMatFile(matFileName,UD,groupIdx,append)





    nargoutchk(0,1);


    [pathstr,name,~]=checkMatFileName(matFileName);


    SBSigSuite=UD.sbobj;



    numGrp=length(groupIdx);
    activeGroup=SBSigSuite.ActiveGroup;

    if~((numGrp==1)&&(groupIdx==activeGroup))

        for idxGrp=groupIdx
            group=SBSigSuite.Groups(idxGrp);
            numSigs=group.NumSignals;
            for idxSig=numSigs:-1:1
                signal=group.Signals(idxSig);
                SBSigSuite.Groups(idxGrp).Signals(idxSig)=signal.removeUnneededPoints;
            end
        end
    end


    ds=SBSigSuite.group2Dataset(groupIdx);%#ok<NASGU>


    gCnt=0;

    dsNameCell=cell(1,length(groupIdx));

    for g=groupIdx
        gCnt=gCnt+1;

        dsNameCell{gCnt}=makeMeaningfulValidName(SBSigSuite.Groups(g).Name);
    end


    dsNameStr='';


    uniqueDsNames=unique(dsNameCell);
    if(length(uniqueDsNames)~=length(dsNameCell))

        dsNameCell=matlab.lang.makeUniqueStrings(dsNameCell);
    end

    for g=1:numel(groupIdx)

        dsName=dsNameCell{g};

        dsNameStr=[dsNameStr,' ',dsName];%#ok<AGROW>

        eval([dsName,'= ds(g);'])
    end

    try

        matFile=fullfile(pathstr,[name,'.mat']);
        isFile=exist(matFile,'file');


        if isFile
            if append

                eval(['save ''',matFile,''' -append ',dsNameStr]);
            else

                error(message('sigbldr_api:signalbuilder:ExistMATFile',matFile,matFile));
            end
        else

            eval(['save ''',matFile,''' ',dsNameStr]);

        end
    catch saveError
        if~append&&isFile
            rethrow(saveError);
        else
            errordlg(getString(message('Sigbldr:sigbldr:ExportError',saveError.message)));
        end
    end

    if nargout>0

        varargout{1}=dsNameCell;
    end

