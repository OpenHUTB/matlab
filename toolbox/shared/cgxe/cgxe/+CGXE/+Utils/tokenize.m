function[tokenList,errorStr,rawTokens]=tokenize(rootDirectory,str,description,searchDirectories,processDollarsAndSeps,doStrictChkOnToken)
























    if(nargin<6)
        doStrictChkOnToken=false;
    end

    if(nargin<5||~isempty(searchDirectories))
        processDollarsAndSeps=true;
    end
    if(nargin<4)
        searchDirectories={};
    end
    if(nargin<3)
        description=str;
    end
    tokenList={};
    errorStr=[];
    rawTokens={};
    if(isempty(str))
        return;
    end

    if processDollarsAndSeps
        [str,errorStr]=process_dollars_and_seps(str,description);
        if(~isempty(errorStr))
            errorStr={errorStr};
            return;
        end
    end

    [tokenList,errorStr,rawTokens]=tokenize_kernel_new(str,rootDirectory,description,searchDirectories,doStrictChkOnToken);


    function[tokenList,allErrorStrs,rawTokens]=tokenize_kernel_new(str,rootDirectory,description,searchDirectories,doStrictChkOnToken)
        tokenList={};
        allErrorStrs={};
        pat='"[^"]+"|[^\n\t\f ;,]+';
        rawTokens=regexp(str,pat,'match');
        for i=1:length(rawTokens)
            token=rawTokens{i};
            [processedToken,errorStr]=process_token(token,rootDirectory,description,searchDirectories,doStrictChkOnToken);%#ok<AGROW>

            if(~isempty(errorStr))
                allErrorStrs{end+1}=errorStr;
            else
                tokenList{end+1}=processedToken;
            end
        end

        function[str,errorStr]=process_dollars_and_seps(str,description)

            errorStr=[];
            dollarLocs=find(str=='$');
            if(length(dollarLocs)/2~=floor(length(dollarLocs)/2))
                errorStr.Msg=DAStudio.message('Simulink:CustomCode:MismatchedDollars',description);
                errorStr.TreatDiagAsError=true;
                return;
            end



            if(~isempty(dollarLocs))
                newStr=str;
                for i=(length(dollarLocs)):-2:2
                    s=dollarLocs(i-1);
                    e=dollarLocs(i);
                    evalStr=str(s+1:e-1);
                    try
                        evalStrValue=evalin('base',evalStr);
                        if(~ischar(evalStrValue))
                            errorStr.Msg=DAStudio.message('Simulink:CustomCode:InvalidDollarString',evalStr,description);
                            errorStr.TreatDiagAsError=true;
                            return;
                        end
                    catch ME
                        errorStr.Msg=DAStudio.message('Simulink:CustomCode:ErrorInDollarString',evalStr,description);
                        errorStr.TreatDiagAsError=true;
                        return;
                    end

                    if(s>1&&e<length(str))
                        newStr=[newStr(1:s-1),evalStrValue,newStr(e+1:end)];
                    elseif(s==1&&e<length(str))
                        newStr=[evalStrValue,newStr(e+1:end)];
                    elseif(s>1&&e==length(str))
                        newStr=[newStr(1:s-1),evalStrValue];
                    else

                        newStr=evalStrValue;
                    end
                end
                str=newStr;
            end
            if isunix
                wrongFilesepChar='\';
                filesepChar='/';
            else
                wrongFilesepChar='/';
                filesepChar='\';
            end

            seps=find(str==wrongFilesepChar);
            if(~isempty(seps))
                str(seps)=filesepChar;
            end


            function[token,errorStr]=process_token(token,rootDirectory,description,searchDirectories,doStrictChkOnToken)

                errorStr=[];
                appendDiagToErrorStr=(doStrictChkOnToken~=-1);
                if length(token)>=2&&token(1)=='"'&&token(end)=='"'
                    token=strip(token(2:end-1));
                end



                if~isempty(token)&&(token(end)=='/'||token(end)=='\')
                    token=token(1:end-1);
                end

                if(~isempty(token))
                    if(token(1)=='.')

                        fullToken=fullfile(rootDirectory,token);
                        if~isfile(fullToken)&&~isfolder(fullToken)&&appendDiagToErrorStr
                            errorStr.Msg=DAStudio.message('Simulink:CustomCode:CustCodeFileNotFoundInSearchDirs',token,description,rootDirectory);
                            errorStr.TreatDiagAsError=doStrictChkOnToken;
                            return;
                        end
                        token=fullToken;
                    else
                        if ispc

                            isAnAbsolutePath=length(token)>=2&&((token(2)==':')||(token(1)=='\'&&token(2)=='\'));
                        else

                            isAnAbsolutePath=token(1)=='/';
                        end
                        if(~isAnAbsolutePath)


                            if(~isempty(searchDirectories))
                                found=0;
                                for i=1:length(searchDirectories)
                                    fullToken=fullfile(searchDirectories{i},token);
                                    if isfile(fullToken)
                                        found=1;
                                        break;
                                    end
                                end
                                if(found)
                                    token=fullToken;
                                else
                                    if(appendDiagToErrorStr)
                                        dirsStr=sprintf('"%s"\n',searchDirectories{:});
                                        errorStr.Msg=DAStudio.message('Simulink:CustomCode:CustCodeFileNotFoundInSearchDirs',token,description,dirsStr);
                                        errorStr.TreatDiagAsError=doStrictChkOnToken;
                                    end
                                    return;
                                end
                            else
                                token=fullfile(rootDirectory,token);
                            end
                        end

                        if~isfile(token)&&~isfolder(token)&&appendDiagToErrorStr
                            dirsStr=sprintf('"%s"\n',searchDirectories{:});
                            errorStr.Msg=DAStudio.message('Simulink:CustomCode:CustCodeFileNotFoundInSearchDirs',token,description,dirsStr);
                            errorStr.TreatDiagAsError=doStrictChkOnToken;
                        end
                    end
                end
