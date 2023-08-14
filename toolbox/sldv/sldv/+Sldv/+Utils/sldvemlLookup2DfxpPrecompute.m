function[mnindx,mxindx,resx,mnindy,mxindy,resy,T,err]=...
    sldvemlLookup2DfxpPrecompute(Tx,Ty,To,x,y,table,nx,ny)




    Nx=3*nx;
    Ny=3*ny;

    bpy=fi(y,Ty);
    bpx=fi(x,Tx);
    bpy.int=y;
    bpx.int=x;

    bpx=double(bpx);
    bpy=double(bpy);

    table_fi=fi(table,To);
    table_fi.int=table;

    nx=length(bpx);
    ny=length(bpy);
    dt_mat=reshape(double(table_fi),nx,ny);

    max_res_x=int32(16);
    max_res_y=int32(16);
    [new_bpx,mnx,mxx,rsx]=...
    Sldv.Utils.sldvemlLookupfxp_even_spaced_bps(bpx,Nx,Tx,max_res_x);
    [new_bpy,mny,mxy,rsy]=...
    Sldv.Utils.sldvemlLookupfxp_even_spaced_bps(bpy,Ny,Ty,max_res_y);

    shrinkBreakpointsIfNecessary();

    new_bpx=double(new_bpx);
    new_bpy=double(new_bpy);

    t=interp2(bpy,bpx',dt_mat,new_bpy,new_bpx','linear');

    mnindx=int32(mnx);
    mxindx=int32(mxx);
    mnindy=int32(mny);
    mxindy=int32(mxy);

    resx=int8(rsx);
    resy=int8(rsy);

    T=fi(t,To);

    err=abs(dt_mat-interp2(new_bpy,new_bpx',t,bpy,bpx','linear'));


    function shrinkBreakpointsIfNecessary()


















        max_combined_bp_size=max(4*numel(table),pow2(18));
        num_bp=numel(new_bpx)*numel(new_bpy);
        if num_bp<=max_combined_bp_size

            return;
        end



        min_num_pow2_bps_to_shave_off=nextpow2(num_bp/max_combined_bp_size);


        num_shave_off_x=0;
        num_shave_off_y=0;


        bloat_factor_x=max(nextpow2(numel(new_bpx))-nextpow2(numel(bpx)),0);
        bloat_factor_y=max(nextpow2(numel(new_bpy))-nextpow2(numel(bpy)),0);



        if bloat_factor_x<bloat_factor_y
            num_shave_off_y=bloat_factor_y-bloat_factor_x;
            min_num_pow2_bps_to_shave_off=min_num_pow2_bps_to_shave_off-num_shave_off_y;
        else
            num_shave_off_x=bloat_factor_x-bloat_factor_y;
            min_num_pow2_bps_to_shave_off=min_num_pow2_bps_to_shave_off-num_shave_off_x;
        end








        if numel(bpx)<numel(bpy)
            num_shave_off_x=num_shave_off_x+ceil(min_num_pow2_bps_to_shave_off/2);
            num_shave_off_y=num_shave_off_y+floor(min_num_pow2_bps_to_shave_off/2);
        else
            num_shave_off_x=num_shave_off_x+floor(min_num_pow2_bps_to_shave_off/2);
            num_shave_off_y=num_shave_off_y+ceil(min_num_pow2_bps_to_shave_off/2);
        end









        max_res_x=max_res_x+num_shave_off_x;
        max_res_y=max_res_y+num_shave_off_y;

        [new_bpx,mnx,mxx,rsx]=...
        Sldv.Utils.sldvemlLookupfxp_even_spaced_bps(bpx,Nx,Tx,max_res_x);
        [new_bpy,mny,mxy,rsy]=...
        Sldv.Utils.sldvemlLookupfxp_even_spaced_bps(bpy,Ny,Ty,max_res_y);
    end
end

function plot_it(bpx,bpy,new_bpx,new_bpy,dt_mat,t)
    figure;
    hold off;
    xx=repmat(bpx,1,length(bpy));
    yy=repmat(bpy',length(bpx),1);
    plot3(xx,yy,dt_mat);
    hold on;
    new_xx=repmat(new_bpx',1,length(new_bpy));
    new_yy=repmat(new_bpy,length(new_bpx),1);
    stem3(new_xx,new_yy,t);
    hold off;
end
