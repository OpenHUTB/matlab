function[options,devs,exts,cls,cols,dests,descs,clips]=...
    postProcessPrinttables(pj,device_table,options)









    useOrigHGPrinting=pj.UseOriginalHGPrinting;

    if~useOrigHGPrinting
        options{end+1}='RGBImage';
        options{end+1}='clipboard';


        if~any(strcmp('v',options))
            options{end+1}='v';
        end


        removeIndexes=strcmp('adobecset',options)|strcmp('epsi',options);
        options(removeIndexes)=[];

    end
    if nargout==1

        return;
    end

    devices=device_table(:,1);
    extensions=device_table(:,2);
    classes=device_table(:,3);
    colorDevs=device_table(:,4);
    destinations=device_table(:,5);
    descriptions=device_table(:,6);
    clipsupport=device_table(:,7);


    if~useOrigHGPrinting
        new_entries_for_device_table=[

        {'prn','','PR','M','P','Printer',0}
        {'prnc','','PR','C','P','Color Printer',0}



        ];

        if~isempty(new_entries_for_device_table)

            devices=[devices;new_entries_for_device_table(:,1)];
            extensions=[extensions;new_entries_for_device_table(:,2)];
            classes=[classes;new_entries_for_device_table(:,3)];
            colorDevs=[colorDevs;new_entries_for_device_table(:,4)];
            destinations=[destinations;new_entries_for_device_table(:,5)];
            descriptions=[descriptions;new_entries_for_device_table(:,6)];
            clipsupport=[clipsupport;new_entries_for_device_table(:,7)];
            device_table=[device_table;new_entries_for_device_table];
        end


        changeIndex=find(strcmp('pdfwrite',devices));
        if~ispc
            changeIndex(end+1)=find(strcmp('bitmap',devices));
        end
        if~isempty(changeIndex)
            clipsupport(changeIndex)={1};
        end

        [removeIndex,~,~,classes,~,~,~]=getDeprecatedDeviceList(device_table);


        devices(removeIndex)=[];
        extensions(removeIndex)=[];
        classes(removeIndex)=[];
        colorDevs(removeIndex)=[];
        destinations(removeIndex)=[];
        descriptions(removeIndex)=[];
        clipsupport(removeIndex)=[];

    end





    devs=devices;
    exts=extensions;
    cls=classes;
    cols=colorDevs;
    dests=destinations;
    descs=descriptions;
    clips=clipsupport;
end




