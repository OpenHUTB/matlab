function[specifiedDTStr,udtMaskParamStr]=getSpecifiedSPCUniDTString(h,blkObj,pathItem,varargin)




    udtMaskParamStr='';
    prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem);

    if~isempty(prefixStr)




        udtMaskParamStr=strcat(prefixStr,'DataTypeStr');
        specifiedDTStr=blkObj.(udtMaskParamStr);

        if~isempty(specifiedDTStr)
            isDTStringFloat=...
            strncmpi(specifiedDTStr,'float',5)||...
            strcmpi(specifiedDTStr,'double')||...
            strcmpi(specifiedDTStr,'single');

            if~isDTStringFloat&&~strncmpi(specifiedDTStr,'Inherit:',8)
                resolvedUDT=slResolve(specifiedDTStr,blkObj.getFullName);
                if isnumerictype(resolvedUDT)||isa(resolvedUDT,'Simulink.NumericType')
                    if resolvedUDT.isfixed
                        if strncmpi(resolvedUDT.Signedness,'auto',4)


                            cannotReturnAutoSignedness=true;
                            if~isempty(varargin)
                                cannotReturnAutoSignedness=varargin{1};
                            end

                            if cannotReturnAutoSignedness






                                switch getInportSignednessString(h,blkObj)
                                case 'Signed'
                                    specifiedDTStr=...
                                    sprintf('fixdt(1,%d,%d)',...
                                    resolvedUDT.WordLength,...
                                    resolvedUDT.FractionLength);
                                case 'Unsigned'
                                    specifiedDTStr=...
                                    sprintf('fixdt(0,%d,%d)',...
                                    resolvedUDT.WordLength,...
                                    resolvedUDT.FractionLength);
                                end
                            end
                        else
                            specifiedDTStr=...
                            sprintf('fixdt(%d,%d,%d)',...
                            resolvedUDT.SignednessBool,...
                            resolvedUDT.WordLength,...
                            resolvedUDT.FractionLength);
                        end
                    end
                end
            end
        end
    else
        specifiedDTStr='';
    end


