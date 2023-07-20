function writeCslHeaderEpilog(h)




    cslfile='host_csl.h';
    epilog='#endif /* _HOST_CSL_H_ */';

    h.findAndWriteCslHeaderEpilog(cslfile,epilog);
