function s=hdlcodegenmsgs(id,latency)






    if hdlgetparameter('isvhdl')
        tlang='VHDL';
        tentity='entity';
        tarch='architecture';
    elseif hdlgetparameter('isverilog')
        tlang='Verilog';
        tentity='module';
        tarch='module body';
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end

    hrefstart='<a href="matlab:edit(''';
    hrefmiddle=''')">';
    hrefend='</a>';

    switch id
    case 1,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:startingcodegen',...
        tlang,hdlgetparameter('filter_name')));

    case 2,
        splitentityarch=hdlgetparameter('split_entity_arch');
        if splitentityarch
            nname=hdlgetparameter('filter_name');
            entityfilename=[nname,...
            hdlgetparameter('split_entity_file_postfix'),...
            hdlgetparameter('filename_suffix')];
            archfilename=[nname,...
            hdlgetparameter('split_arch_file_postfix'),...
            hdlgetparameter('filename_suffix')];
            [pathstr,~]=fileparts(fullfile(hdlGetCodegendir,entityfilename));
            entitynameforuser=fullfile(pathstr,entityfilename);
            if~isempty(pathstr)
                whatstruct=what(pathstr);
                whatstruct=whatstruct(end);
                if~isempty(whatstruct)
                    entitynameforuser=fullfile(whatstruct.path,entityfilename);
                end
            end
            [pathstr,~]=fileparts(fullfile(hdlGetCodegendir,archfilename));
            archnameforuser=fullfile(pathstr,archfilename);
            if~isempty(pathstr)
                whatstruct=what(pathstr);
                whatstruct=whatstruct(end);
                if~isempty(whatstruct)
                    archnameforuser=fullfile(whatstruct.path,archfilename);
                end
            end
            s=[getString(message('HDLShared:hdlfilter:codegenmessage:gencodeentity',...
            hrefstart,hrefmiddle,hrefend,entitynameforuser,entitynameforuser))...
            ,getString(message('HDLShared:hdlfilter:codegenmessage:gencodearch',...
            hrefstart,hrefmiddle,hrefend,archnameforuser,archnameforuser))];
...
...
...
...
        else
            fullfilename=[hdlgetparameter('filter_name'),hdlgetparameter('filename_suffix')];
            [pathstr,~]=fileparts(fullfile(hdlGetCodegendir,fullfilename));


            nameforuser=fullfile(pathstr,fullfilename);
            if~isempty(pathstr)
                whatstruct=what(pathstr);
                whatstruct=whatstruct(end);
                if~isempty(whatstruct)
                    nameforuser=fullfile(whatstruct.path,fullfilename);
                end
            end
            s=getString(message('HDLShared:hdlfilter:codegenmessage:gencodefilename',...
            hrefstart,hrefmiddle,hrefend,nameforuser,nameforuser));

        end
    case 3,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:startgencodeentityorarch',...
        hdlgetparameter('filter_name'),tlang,tentity));

    case 4,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:startgencodeentityorarch',...
        hdlgetparameter('filter_name'),tlang,tarch));

    case 5,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:fos'));

    case 6,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:sos'));

    case 7,










        s=getString(message('HDLShared:hdlfilter:codegenmessage:completion',...
        tlang,hdlgetparameter('filter_name')));



    case 8,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:integsec'));

    case 9,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:combsec'));

    case 10,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:cascadestage'));

    case 11,
        s=getString(message('HDLShared:hdlfilter:codegenmessage:hashmarks'));

    end
