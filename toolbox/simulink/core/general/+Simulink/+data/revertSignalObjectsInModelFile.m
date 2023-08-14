function revertSignalObjectsInModelFile(srcFile)






    info=Simulink.MDLInfo(srcFile);
    encoding=info.SavedCharacterEncoding;


    [srcID,msg]=fopen(srcFile,'r','n',encoding);
    if srcID==-1
        DAStudio.error('Simulink:LoadSave:FileReadError',srcFile,msg);
    end


    dstFile=[tempname,'.mdl'];

    [dstID,msg]=fopen(dstFile,'w','n',encoding);
    if dstID==-1
        fclose(srcID);
        DAStudio.error('Simulink:LoadSave:FileWriteError',dstFile,msg);
    end

    try
        inObject=false;
        objDepth=0;
        objBuffer='';

        nextLine=fgets(srcID);
        while~isequal(nextLine,-1)
            if(~inObject&&(isequal(regexp(nextLine,'\s+Object {\s*\n'),1)))

                inObject=true;
            end

            if inObject

                objBuffer=[objBuffer,nextLine];%#ok

                if(regexp(nextLine,'\s+[\w\.]+ {\s*\n')==1)

                    objDepth=objDepth+1;
                elseif(regexp(nextLine,'\s+}\s*\n')==1)

                    objDepth=objDepth-1;

                    if(objDepth==0)

                        startOfSignalObject=regexp(objBuffer,'\$PropName\s+"SignalObject"\s*\n');
                        if~isempty(startOfSignalObject)

                            className=regexp(objBuffer,'\s+\$ClassName\s+"(\w+\.\w+)"\s*\n','tokens');
                            cscPackageName=regexp(objBuffer,'\s+CSCPackageName\s+"(\w+)"\s*\n','tokens');
                            paramOrSignal=regexp(objBuffer,'\s+ParameterOrSignal\s+"(\w+)"\s*\n','tokens');
                            assert(isscalar(startOfSignalObject));
                            assert(isscalar(className)&&isscalar(className{1}));
                            assert(isscalar(cscPackageName)&&isscalar(cscPackageName{1}));
                            assert(isscalar(paramOrSignal)&&isscalar(paramOrSignal{1}));
                            assert(strcmp(paramOrSignal{1}{1},'Signal'));


                            cscPackageName=cscPackageName{1}{1};
                            switch cscPackageName
                            case 'Simulink'
                                rtwInfoClass='Simulink.SignalRTWInfo';
                            case 'mpt'
                                rtwInfoClass='mpt.CustomRTWInfoSignal';
                            otherwise
                                rtwInfoClass=[cscPackageName,'.CustomRTWInfo_Signal'];
                            end


                            objBuffer=strrep(objBuffer,...
                            'Object {',[className{1}{1},' {']);

                            objBuffer=strrep(objBuffer,...
                            'Simulink.CoderInfo {',[rtwInfoClass,' {']);


                            objBuffer=l_RemoveLine(objBuffer,'\s+\$ClassName\s+"\w+\.\w+"\s*\n');
                            objBuffer=l_RemoveLine(objBuffer,'\s+CSCPackageName\s+"\w+"\s*\n');
                            objBuffer=l_RemoveLine(objBuffer,'\s+ParameterOrSignal\s+"\w+"\s*\n');
                        end

                        fprintf(dstID,'%s',objBuffer);
                        objBuffer='';
                        inObject=false;
                    end
                end
            else


                fprintf(dstID,'%s',nextLine);
            end

            nextLine=fgets(srcID);
        end

        fclose(srcID);
        fclose(dstID);

    catch e
        fclose(srcID);
        fclose(dstID);
        delete(dstFile);
        DAStudio.error('Simulink:LoadSave:FileWriteError',dstFile,e.message);
    end


    delete(srcFile);
    success=movefile(dstFile,srcFile,'f');
    assert(success);
end


function objBuffer=l_RemoveLine(objBuffer,pattern)

    startOfLine=regexp(objBuffer,pattern);
    endOfLines=regexp(objBuffer,'\s*\n');
    assert(length(startOfLine)==1);


    endOfLines=endOfLines(endOfLines>startOfLine);

    objBuffer((startOfLine+1):endOfLines(1))='';

end


