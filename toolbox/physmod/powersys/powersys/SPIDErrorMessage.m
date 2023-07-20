function SPIDErrorMessage(unDetMat,MgColNames,ErrorData)









    try
        sys=bdroot(gcb);

        nStates=ErrorData.nStates;
        nInputs=ErrorData.nInputs;
        nOutputs=ErrorData.nOutputs;
        nSwitch=ErrorData.nSwitch;

        MatIdx=[nStates,nInputs,nStates,nSwitch];
        MatIdx=int32(cumsum(double(MatIdx)));

        XIdx=(1:MatIdx(1));
        UIdx=MatIdx(1)+1:MatIdx(2);
        DIdx=MatIdx(2)+1:MatIdx(3);
        SwRIdx=MatIdx(3)+1:MatIdx(4);

        if nSwitch>0
            SwR=(nStates+nOutputs)+(1-ErrorData.SwitchStatus)*MatIdx(4)+(1:1:nSwitch);
        else
            SwR=(nStates+nOutputs);
        end

        MgColNames=deblank(mat2cell(MgColNames,ones(size(MgColNames,1),1),size(MgColNames,2)));
        ColNames=cell(MatIdx(4),1);
        ColNames([XIdx,UIdx,DIdx])=MgColNames((nStates+nOutputs+nSwitch)+[XIdx,UIdx,DIdx]);
        ColNames(SwRIdx)=MgColNames(SwR);

        [ErrorBoxTitle,ErrorTime,TitleStr,TypeStr,FormatStr,ErrorID]=SPIDErrorEngMsgTxt;


        if(ErrorData.ErrorCode==2)
            clear ErrorMsg;
            ErrorMsg={sprintf(ErrorTime,ErrorData.ErrorTime)};
            ErrorMsg=[ErrorMsg;sprintf('\n'),TitleStr{5}];
            ErrorMsg=['Error in ',sys,' model.';' ';ErrorMsg];
            powericon('psberror',ErrorMsg,ErrorID{5},'NoUIwait');
            return;
        end;


        UniqueErrorMessage=0;
        unDetMat=unique(unDetMat,'rows');
        for n=1:size(unDetMat,1)
            clear ErrorMsg;
            ErrorCode=0;
            if(any(unDetMat(n,[XIdx,UIdx])))
                if(any(unDetMat(n,XIdx)))
                    ErrorCode=ErrorCode+1;
                end;
                if(any(unDetMat(n,UIdx)))
                    ErrorCode=ErrorCode+2;
                end;
            end;
            if(ErrorCode==0)
                continue;
            end;
            ErrorMsg={sprintf(ErrorTime,ErrorData.ErrorTime)};
            ErrorRow=unDetMat(n,:);
            switch(ErrorCode)
            case 1
                [numStates,StatesIndex,StatesType,StatesName,StatesVal]=GetVarData(ColNames,ErrorRow,ErrorData.States,XIdx,1e-6);
                if(isempty(numStates))
                    continue;
                end;
                ErrorMsg=[ErrorMsg;GetErrorMsg(TitleStr(2,:,1),TypeStr(2,:,1),FormatStr(2,:,1),StatesIndex,StatesType,StatesName,StatesVal)];%#ok mlink
                [numSwitch,SwitchIndex,SwitchType,SwitchName,SwitchVal]=GetVarData(ColNames,ErrorRow,ErrorData.SwitchStatus,SwRIdx,0.0);
                if(isempty(numSwitch))
                    continue;
                end;
                ErrorMsg=[ErrorMsg;GetErrorMsg(TitleStr(2,:,2),TypeStr(2,:,2),FormatStr(2,:,2),SwitchIndex,SwitchType,SwitchName,SwitchVal)];%#ok mlink
            case 2
                [numSource,SourceIndex,SourceType,SourceName,SourceVal]=GetVarData(ColNames,ErrorRow,ErrorData.Inputs,UIdx,1e-6);
                if(isempty(numSource))
                    continue;
                end;
                ErrorMsg=[ErrorMsg;GetErrorMsg(TitleStr(3,:,1),TypeStr(3,:,1),FormatStr(3,:,1),SourceIndex,SourceType,SourceName,SourceVal)];%#ok mlink
                [numSwitch,SwitchIndex,SwitchType,SwitchName,SwitchVal]=GetVarData(ColNames,ErrorRow,ErrorData.SwitchStatus,SwRIdx,0.0);
                if(isempty(numSwitch))
                    continue;
                end;
                ErrorMsg=[ErrorMsg;GetErrorMsg(TitleStr(3,:,2),TypeStr(3,:,2),FormatStr(3,:,2),SwitchIndex,SwitchType,SwitchName,SwitchVal)];%#ok mlink
            case 3
                [numStates,StatesIndex,StatesType,StatesName,StatesVal]=GetVarData(ColNames,ErrorRow,ErrorData.States,XIdx,0.0);
                if(isempty(numStates))
                    continue;
                end;
                ErrorMsg=[ErrorMsg;GetErrorMsg(TitleStr(4,:,1),TypeStr(4,:,1),FormatStr(4,:,1),StatesIndex,StatesType,StatesName,StatesVal)];%#ok mlink
                [numSource,SourceIndex,SourceType,SourceName,SourceVal]=GetVarData(ColNames,ErrorRow,ErrorData.Inputs,UIdx,0.0);
                if(isempty(numSource))
                    continue;
                end;
                ErrorMsg=[ErrorMsg;GetErrorMsg(TitleStr(4,:,2),TypeStr(4,:,2),FormatStr(4,:,2),SourceIndex,SourceType,SourceName,SourceVal)];%#ok mlink
                [numSwitch,SwitchIndex,SwitchType,SwitchName,SwitchVal]=GetVarData(ColNames,ErrorRow,ErrorData.SwitchStatus,SwRIdx,0.0);










                if(~isempty(numSwitch))
                    ErrorMsg=[ErrorMsg;GetErrorMsg(TitleStr(4,:,3),TypeStr(4,:,3),FormatStr(4,:,3),SwitchIndex,SwitchType,SwitchName,SwitchVal)];%#ok mlink
                else


                    UniqueErrorMessage=1;
                end

            end
            ErrorMsg=['Error in ',sys,' model.';' ';ErrorMsg];
            powericon('psberror',ErrorMsg,ErrorID{ErrorCode+1},'NoUIwait');
            if UniqueErrorMessage
                break
            end
        end;
    catch ME
        disp(['An error occurred in SPIDErrorMessage.m function. Simulink reported the following error message: ',ME.message]);
    end



    function[numVar,VarIdx,VarType,VarName,VarVal]=GetVarData(ColNames,ErrorRow,VarVal,VarIdx,ValTol)
        numVar=find(ErrorRow(VarIdx)~=0);
        VarIdx=VarIdx(numVar);
        VarVal=VarVal(numVar);
        Val=ErrorRow(VarIdx).*double(VarVal);
        if(abs(sum(Val))<ValTol)
            numVar=[];
            VarType=[];
            VarName=[];
            return;
        end;
        SwTagIdx=cell2mat(strfind(ColNames(VarIdx),'SPID'));
        if(~isempty(SwTagIdx))
            [VarType,VarName]=strtok(ColNames(VarIdx),' ');
        else
            [VarType,VarName]=strtok(ColNames(VarIdx),'_');
            [toto,VarName]=strtok(VarName,'_');
            for i=1:size(VarName,1)
                if(isempty(VarName{i}))
                    VarName{i}=toto{i};
                end;
                if((VarName{i}(1)=='_')||(VarName{i}(1)==' '))
                    VarName{i}=VarName{i}(2:end);
                end;
            end;
        end;


        function ErrorMsg=GetErrorMsg(TitleStr,TypeStr,FormatStr,VarIdx,VarType,VarName,VarVal)
            ErrorMsg=[];
            if(length(VarIdx)==1)
                if(strcmp(VarType,TypeStr{1}))
                    ErrorMsg=[sprintf('\n'),TitleStr{1}];
                    ErrorMsg=[ErrorMsg;{sprintf(FormatStr{1},char(VarName),VarVal)}];
                end;
                if(strcmp(VarType,TypeStr{2}))
                    ErrorMsg=[sprintf('\n'),TitleStr{2}];
                    ErrorMsg=[ErrorMsg;{sprintf(FormatStr{2},char(VarName),VarVal)}];
                end;
            else
                if(strcmp(VarType(1),TypeStr{1}))
                    ErrorMsg=[sprintf('\n'),TitleStr{3}];
                    for i=1:length(VarIdx)
                        ErrorMsg=[ErrorMsg;{sprintf(FormatStr{1},char(VarName(i)),VarVal(i))}];
                    end;
                end;
                if(strcmp(VarType(1),TypeStr{2}))
                    ErrorMsg=[sprintf('\n'),TitleStr{4}];
                    for i=1:length(VarIdx)
                        ErrorMsg=[ErrorMsg;{sprintf(FormatStr{2},char(VarName(i)),VarVal(i))}];
                    end;
                end;
            end;


