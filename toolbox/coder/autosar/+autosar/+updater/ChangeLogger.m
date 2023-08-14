classdef ChangeLogger<handle








    properties(Access=private)
        AutomaticChangeStrs;
        ManualChangeStrs;
        MetaModelChangeStrs;
        WorkSpaceChangeStrs;
        FilterObjectMap;
    end

    methods



        function self=ChangeLogger()
            self.AutomaticChangeStrs={};
            self.ManualChangeStrs={};
            self.MetaModelChangeStrs={};
            self.WorkSpaceChangeStrs={};
            self.FilterObjectMap=containers.Map(...
            'KeyType','char',...
            'ValueType','any'...
            );
        end


        function newLogger=clone(self)
            newLogger=autosar.updater.ChangeLogger();
            newLogger.AutomaticChangeStrs=self.AutomaticChangeStrs;
            newLogger.ManualChangeStrs=self.ManualChangeStrs;
            newLogger.MetaModelChangeStrs=self.MetaModelChangeStrs;
            newLogger.WorkSpaceChangeStrs=self.WorkSpaceChangeStrs;
            if~self.FilterObjectMap.isempty()
                newLogger.FilterObjectMap=containers.Map(...
                self.FilterObjectMap.keys,self.FilterObjectMap.values);
            end
        end



        function outStrings=getLog(self,natureOfChange)
            switch natureOfChange
            case 'Automatic'
                outStrings=self.AutomaticChangeStrs;
            case 'Manual'
                outStrings=self.ManualChangeStrs;
            case 'MetaModel'
                outStrings=autosar.updater.ChangeLogger.sortMetaModelChanges(self.MetaModelChangeStrs);
            case 'WorkSpace'
                outStrings=self.WorkSpaceChangeStrs;
            otherwise
                assert(false,'natureOfChange needs to be one of ''Automatic'', ''Manual'', or ''MetaModel''.');
            end
        end




        function removeLog(self,natureOfChange,indicesToRemove)
            switch natureOfChange
            case 'Automatic'
                self.AutomaticChangeStrs(indicesToRemove)=[];
            case 'Manual'
                self.ManualChangeStrs(indicesToRemove)=[];
            case 'MetaModel'
                self.MetaModelChangeStrs(indicesToRemove)=[];
            case 'WorkSpace'
                self.WorkSpaceChangeStrs(indicesToRemove)=[];
            otherwise
                assert(false,'natureOfChange needs to be one of ''Automatic'', ''Manual'', or ''MetaModel''.');
            end
        end




        function logAddition(self,natureOfChange,objectType,objectName,parentName,autosarName)




            narginchk(4,6);

            if nargin==4
                if strcmp(natureOfChange,'Automatic')
                    if strcmp(objectType,message('RTW:autosar:updateReportSignalLineLabel').getString())

                        blkHyperlink=objectName;
                    else
                        blkHyperlink=autosar.updater.Report.getBlkHyperlink(objectName);
                    end
                    log=message('RTW:autosar:logAdditionAutomatic',objectType,blkHyperlink);


                    self.FilterObjectMap(objectName)=true;
                else
                    log=message('RTW:autosar:logAdditionAutomatic',objectType,objectName);
                end

            elseif nargin==5
                if strcmp(natureOfChange,'MetaModel')
                    log=message('autosarstandard:importer:logAdditionAutomaticRef',objectType,objectName,parentName);
                else
                    log=message('RTW:autosar:logAdditionManualShort',objectType,objectName,parentName);
                end
            else
                log=message('RTW:autosar:logAdditionManual',objectType,objectName,autosarName,parentName);
            end

            logMessage=log.getString();

            switch natureOfChange
            case 'Automatic'
                self.AutomaticChangeStrs{end+1}=logMessage;
            case 'Manual'
                self.ManualChangeStrs{end+1}=logMessage;
            case 'MetaModel'
                self.MetaModelChangeStrs{end+1}=logMessage;
            case 'WorkSpace'
                self.WorkSpaceChangeStrs{end+1}=logMessage;
            otherwise
                assert(false,'natureOfChange needs to be one of ''Automatic'', ''Manual'', ''WorkSpace'' or ''MetaModel''.');
            end
        end




        function logDeletion(self,natureOfChange,objectType,objectName,parentName)


            narginchk(4,5)
            if nargin==4
                log=message('RTW:autosar:logDeletionAutomatic',objectType,objectName);
            elseif nargin==5
                if strcmp(natureOfChange,'MetaModel')
                    log=message('autosarstandard:importer:logDeletionAutomaticRef',objectType,objectName,parentName);
                else
                    log=message('RTW:autosar:logDeletionManual',objectType,objectName,parentName);
                end
            end

            logMessage=log.getString();

            switch natureOfChange
            case 'Automatic'
                self.AutomaticChangeStrs{end+1}=logMessage;
            case 'Manual'
                self.ManualChangeStrs{end+1}=logMessage;
            case 'MetaModel'
                self.MetaModelChangeStrs{end+1}=logMessage;
            case 'WorkSpace'
                self.WorkSpaceChangeStrs{end+1}=logMessage;
            otherwise
                assert(false,'natureOfChange needs to be one of ''Automatic'', ''Manual'', ''WorkSpace'' or ''MetaModel''.');
            end
        end




        function logModification(self,natureOfChange,field,objectType,objectName,old,new)


            narginchk(5,7);
            useShortMessages=(nargin<7);

            if useShortMessages
                log=message('RTW:autosar:logModificationAutomaticShort',field,objectType,objectName);
            else
                log=message('RTW:autosar:logModificationAutomatic',field,objectType,objectName,old,new);
            end
            logMessage=log.getString();

            switch natureOfChange
            case 'Automatic'
                if self.FilterObjectMap.isKey(objectName)

                else
                    assert(~useShortMessages,'Cannot handle Automatic Short messages for Simulink changes');
                    blkHyperlink=autosar.updater.ChangeLogger.getBlockHyperlink(objectType,objectName);
                    log=message('RTW:autosar:logModificationAutomatic',field,objectType,blkHyperlink,old,new);
                    self.AutomaticChangeStrs{end+1}=log.getString();
                end
            case 'Manual'
                if self.FilterObjectMap.isKey(objectName)

                else
                    if useShortMessages
                        assert(isempty(field),'logModificationManualShort is not capable of displaying field');
                        log=message('RTW:autosar:logModificationManualShort',objectType,objectName);
                    else
                        blkHyperlink=autosar.updater.ChangeLogger.getBlockHyperlink(objectType,objectName);
                        log=message('RTW:autosar:logModificationManual',field,objectType,blkHyperlink,old,new);
                    end
                    self.ManualChangeStrs{end+1}=log.getString();
                end
            case 'MetaModel'
                self.MetaModelChangeStrs{end+1}=logMessage;
            case 'WorkSpace'
                self.WorkSpaceChangeStrs{end+1}=logMessage;
            otherwise
                assert(false,'natureOfChange needs to be one of ''Automatic'', ''Manual'', ''WorkSpace'' or ''MetaModel''.');
            end
        end
    end

    methods(Static,Access=private)
        function blkHyperlink=getBlockHyperlink(objectType,objectName)
            if any(strcmp(objectType,{'Simulink data transfer','Data Default'}))
                blkHyperlink=objectName;
            else
                blkHyperlink=autosar.updater.Report.getBlkHyperlink(objectName);
            end
        end

        function outStrings=sortMetaModelChanges(inStrings)




            addedStrs=inStrings(contains(inStrings,'class="add"'));
            deletedStrs=inStrings(contains(inStrings,'class="delete"'));
            updatedStrs=inStrings(contains(inStrings,'class="update"'));
            outStrings=[addedStrs,deletedStrs,updatedStrs];
        end
    end
end














