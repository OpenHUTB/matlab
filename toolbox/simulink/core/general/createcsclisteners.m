function createcsclisteners(hThisClass)








    l_EnforceThatCustomAttributesIsAfterCustomStorageClass(hThisClass);
    l_CheckForObsoleteCSCs(hThisClass);

    hSLRTWInfoClass=findclass(findpackage('Simulink'),'BaseRTWInfo');


    hSLRTWInfoSCProp=findprop(hSLRTWInfoClass,'StorageClass');
    hSCProp=findprop(hThisClass,'StorageClass');
    hSCListener=handle.listener(hSLRTWInfoClass,hSLRTWInfoSCProp,...
    'PropertyPostSet',@SCListener);
    schema.prop(hSCProp,'SC_Listener','handle');
    hSCProp.SC_Listener=hSCListener;


    hCSCProp=findprop(hThisClass,'CustomStorageClass');
    hCSCListener=handle.listener(hThisClass,hCSCProp,...
    'PropertyPostSet',@CSCListener);
    schema.prop(hCSCProp,'CSC_Listener','handle');
    hCSCProp.CSC_Listener=hCSCListener;






    function SCListener(~,eventData)
        storageclasschanged(eventData.AffectedObject);





        function CSCListener(~,eventData)

            CustomStorageClassListener(eventData.AffectedObject);



            function l_EnforceThatCustomAttributesIsAfterCustomStorageClass(hThisClass)










                propStruct=hThisClass.Properties.get;
                propNames={propStruct(:).Name}';
                cscIdx=find(strcmp(propNames,'CustomStorageClass'));
                caIdx=find(strcmp(propNames,'CustomAttributes'));

                if(cscIdx>caIdx)

                    schema.prop(hThisClass,'CustomAttributes','Simulink.BaseCSCAttributes');


                    errorAndDeleteClass('Simulink:util:NeedToRegenerateClasses',hThisClass);
                end


                hPropCSC=findprop(hThisClass,'CustomStorageClass');
                hPropCA=findprop(hThisClass,'CustomAttributes');


                hPropCSC.AccessFlags.AbortSet='on';


                assert(isequal(hPropCA.AccessFlags.PublicSet,'on'));


                hPropCA.AccessFlags.PublicSet='off';


                assert(isequal(hPropCA.AccessFlags.AbortSet,'on'));
                hPropCA.AccessFlags.AbortSet='off';


                function l_CheckForObsoleteCSCs(hThisClass)




                    hPackage=hThisClass.Package;
                    hSuperClass=hThisClass.SuperClasses;

                    assert(length(hPackage)==1);
                    assert(length(hSuperClass)==1);


                    if~(strcmp(hSuperClass.Package.Name,'Simulink')&&...
                        strcmp(hSuperClass.Name,'CustomRTWInfo'))

                        return;
                    end


                    packageName=hPackage.Name;
                    packageDir=['@',packageName,filesep];
                    packageDefnFile=which([packageDir,'packagedefn.mat']);

                    if~isempty(packageDefnFile)

                        matFileData=load([packageDir,'packagedefn.mat']);
                        switch matFileData.hThisPackageDefn.CSCHandlingMode
                        case 'v1 - Manually defined'
                            errorAndDeleteClass('Simulink:util:UpgradeCSCInfrastructure',hThisClass);
                        case 'v2 - CSC Registration File'
                            if(isequal(hThisClass.Name,'CustomRTWInfo_Parameter')||...
                                isequal(hThisClass.Name,'CustomRTWInfo_Signal'))

                            else
                                errorAndDeleteClass('Simulink:util:UsingOldRTWInfoClass',hThisClass);
                            end
                        otherwise
                            assert(false,'Unexpected CSCHandlingMode')
                        end
                    else

                        cscRegFile=which([packageDir,'csc_registration']);
                        if isempty(cscRegFile)

                            errorAndDeleteClass('Simulink:util:ObsoleteCSCInfrastructure',hThisClass);
                        else

                            if(isequal(hThisClass.Name,'CustomRTWInfo_Parameter')||...
                                isequal(hThisClass.Name,'CustomRTWInfo_Signal'))

                            elseif(isequal(local_FullClassName(hThisClass),'mpt.CustomRTWInfoParameter')||...
                                isequal(local_FullClassName(hThisClass),'mpt.CustomRTWInfoSignal'))

                            else
                                errorAndDeleteClass('Simulink:util:UsingOldRTWInfoClass',hThisClass);
                            end
                        end
                    end

                    function fullClassName=local_FullClassName(hThisClass)
                        fullClassName=[hThisClass.Package.Name,'.',hThisClass.Name];

                        function errorAndDeleteClass(messageID,hThisClass)
                            className=local_FullClassName(hThisClass);
                            delete(hThisClass);
                            DAStudio.error(messageID,className);


