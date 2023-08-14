function setVhdlPackageName(this,p)




    if this.getParameter('isvhdl')
        this.setParameter('vhdl_package_required',p.VhdlPackageGenerated);
        topName=p.getTopNetwork.Name;

        this.setParameter('vhdl_package_name',...
        [topName,this.getParameter('package_suffix')]);
    end
