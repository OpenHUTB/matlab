function hdlsetpackagename(name)







    hdlsetparameter('vhdl_package_name',...
    hdluniqueentityname([name,hdlgetparameter('package_suffix')]));
    hdladdtoentitylist('',hdlgetparameter('vhdl_package_name'),'','');





