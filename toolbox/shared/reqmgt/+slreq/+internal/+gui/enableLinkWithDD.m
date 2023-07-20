function r=enableLinkWithDD()
    r=struct('name',getString(message('Slvnv:slreq:LinkWithDD')),...
    'tag','','callback','','accel','','enabled',true,'visible',true,'me',[]);

    [dFile,dpath,label,r.me]=rmide.getSelection;
    if startsWith(label,'ERROR: ')
        r.enabled=false;
    else
        r.enabled=true;
    end
end