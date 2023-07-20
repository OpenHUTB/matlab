classdef FirmwareUpdater<hwconnectinstaller.internal.PackageInfo





    properties
SupportPkg

hFwUpdate

        BaseCodeToFilterFwUpdate={};















BaseCodeForSelectedSpPkg







    end

    methods


        function[fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList]=getFirmwareUpdateList(obj)








            if~hwconnectinstaller.internal.isAddOnsSSIEnabled


                spPkg=obj.getAllPackagesOnPath();
                [fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList]=...
                hwconnectinstaller.FirmwareUpdater.getFilteredFirmwareUpdateList(spPkg,obj.BaseCodeToFilterFwUpdate);
            else
                fwUpdateDisplayList={};
                fwUpdateList={};
                fwUpdateBaseCodeList={};

                legacyInfoObjs=...
                matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase.findAllSpPkgLegacyInfoOnPath();
                if isempty(legacyInfoObjs)
                    return
                end



                fwUpdateDisplayList={legacyInfoObjs.FwUpdateDisplayName};
                fwUpdateList={legacyInfoObjs.FwUpdate};
                fwUpdateBaseCodeList={legacyInfoObjs.BaseCode};
                nonEmptyIdx=~cellfun(@isempty,fwUpdateList);

                [fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList]=...
                obj.filterFwUpdateLists(fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList,nonEmptyIdx);

                if~isempty(obj.BaseCodeToFilterFwUpdate)



                    baseCodeList={legacyInfoObjs.BaseCode};
                    baseCodeList=baseCodeList(nonEmptyIdx);
                    idx=ismember(baseCodeList,obj.BaseCodeToFilterFwUpdate);
                    [fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList]=...
                    obj.filterFwUpdateLists(fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList,idx);
                end




                combinedFwUpdateSet=strcat(fwUpdateList,fwUpdateDisplayList);
                [~,uniqueIndex]=unique(combinedFwUpdateSet,'stable');
                [fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList]=...
                obj.filterFwUpdateLists(fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList,uniqueIndex);

            end
        end

        function steps=getFirmwareUpdateSteps(obj,fwUpdate)
            validateattributes(fwUpdate,{'char'},{'nonempty'},...
            'getFirmwareUpdateSteps','fwUpdate');
            assert(~isempty(which(fwUpdate)),['Firmware Update class ',fwUpdate,' not on MATLAB path']);

            try
                obj.hFwUpdate=feval(fwUpdate);
            catch ex
                error(message('hwconnectinstaller:setup:FwUdpateEvalFailure'))
            end

            assert(ismethod(obj.hFwUpdate,'getFirmwareUpdateSteps'));
            steps=obj.hFwUpdate.getFirmwareUpdateSteps();

            steps(end+1)=hwconnectinstaller.Step('FirmwareUpdateComplete',...
            @hwconnectinstaller.internal.getFirmwareUpdateCompleteSchema,...
            @hwconnectinstaller.internal.executeFirmwareUpdateComplete);
        end

        function release(obj)

            obj.SupportPkg=[];
            obj.hFwUpdate=[];
        end
    end

    methods(Static,Hidden)
        function ret=classExists(name)
            ret=(exist(name,'class')==8);
        end

        function[fwUpdateList,fwUpdateDisplayList,fwBaseCodeList]=getFilteredFirmwareUpdateList(spPkg,baseCodeFilter)























            validateattributes(spPkg,{'hwconnectinstaller.SupportPackage'},...
            {},'getFilteredFirmwareUpdateList','spPkg');
            validateattributes(baseCodeFilter,{'char','cell'},...
            {},'getFilteredFirmwareUpdateList','baseCodeFilter');

            nonemptyIndex=not(cellfun('isempty',{spPkg.FwUpdate}));
            spPkgWithFwUpdate=spPkg(nonemptyIndex);

            baseCodeList={spPkgWithFwUpdate.BaseCode};
            if~isempty(baseCodeFilter)
                baseCodeFilterIdx=ismember(baseCodeList,baseCodeFilter);
                selectedSpPkgWithFwUpdate=spPkgWithFwUpdate(baseCodeFilterIdx);
            else
                selectedSpPkgWithFwUpdate=spPkgWithFwUpdate;
            end




            if isempty(selectedSpPkgWithFwUpdate)
                fwUpdateDisplayList={};
                fwUpdateList={};
                fwBaseCodeList={};
                return
            end


            spPkgNameList={selectedSpPkgWithFwUpdate.Name};



            fwUpdateList={selectedSpPkgWithFwUpdate.FwUpdate};
            fwUpdateDisplayList={selectedSpPkgWithFwUpdate.FwUpdateDisplayName};
            fwBaseCodeList={selectedSpPkgWithFwUpdate.BaseCode};


            for i=1:numel(fwUpdateDisplayList)
                if~isempty(fwUpdateDisplayList{i})
                    continue;
                end

                fwUpdateDisplayList{i}=...
                hwconnectinstaller.FirmwareUpdater.getDefaultFwUpdateDisplayName(...
                selectedSpPkgWithFwUpdate(i).DisplayName,selectedSpPkgWithFwUpdate(i).BaseProduct);
            end

            combinedFwUpdateSet=strcat(fwUpdateList,fwUpdateDisplayList);

            hwconnectinstaller.internal.inform(sprintf(...
            'FirmwareUpdater: Before filtering, there are %d support packages with FwUpdate.',...
            length(combinedFwUpdateSet)));
            unFilteredList=strcat(spPkgNameList','--',fwUpdateList','--',fwUpdateDisplayList');
            hwconnectinstaller.internal.inform(sprintf('\n  %s',unFilteredList{:}));


            spPkgWithFwUpdateInstalledDateNum={};
            spPkgWithFwUpdateInstalledDate={selectedSpPkgWithFwUpdate.InstalledDate};

            isInstalledDateEmpty=cellfun(@isempty,spPkgWithFwUpdateInstalledDate);
            try


                if all(~isInstalledDateEmpty)
                    spPkgWithFwUpdateInstalledDateNum=cellfun(@datenum,spPkgWithFwUpdateInstalledDate);





                end
            catch




            end






            if~isempty(spPkgWithFwUpdateInstalledDateNum)
                [~,sortIdx]=sort(spPkgWithFwUpdateInstalledDateNum);
                combinedFwUpdateSet=combinedFwUpdateSet(sortIdx);
                fwUpdateDisplayList=fwUpdateDisplayList(sortIdx);
                fwUpdateList=fwUpdateList(sortIdx);
                spPkgNameList=spPkgNameList(sortIdx);
                fwBaseCodeList=fwBaseCodeList(sortIdx);
            end



            [~,uniqueIndex]=unique(combinedFwUpdateSet,'stable');
            fwUpdateDisplayList=fwUpdateDisplayList(uniqueIndex);
            spPkgNameList=spPkgNameList(uniqueIndex);
            fwUpdateList=fwUpdateList(uniqueIndex);
            fwBaseCodeList=fwBaseCodeList(uniqueIndex);

            hwconnectinstaller.internal.inform(sprintf(...
            'FirmwareUpdater: After filtering, there are %d support packages for users to select.',...
            length(fwUpdateDisplayList)));
            filteredList=strcat(spPkgNameList','--',fwUpdateList','--',fwUpdateDisplayList');
            hwconnectinstaller.internal.inform(sprintf('\n  %s',filteredList{:}));
        end


        function fwupdateDisplayName=getDefaultFwUpdateDisplayName(spkgDisplayName,baseProduct)
            fwupdateDisplayName=[spkgDisplayName,' (',baseProduct,')'];
        end

        function[fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList]=...
            filterFwUpdateLists(fwUpdateList,fwUpdateDisplayList,fwUpdateBaseCodeList,idx);

            fwUpdateDisplayList=fwUpdateDisplayList(idx);
            fwUpdateList=fwUpdateList(idx);
            fwUpdateBaseCodeList=fwUpdateBaseCodeList(idx);
        end

    end

end
