// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   DownloadService.java

package com.mathworks.internal.dws.client.v3;

import java.rmi.RemoteException;

// Referenced classes of package com.mathworks.internal.dws.client.v3:
//            BitVer, GetUpdatedSoftwareWithinReleaseAndArchReturn, GetUpdatedSoftwareWithinPasscodeAndArchReturn, GetSoftwareProductInfoByLicenseAndArchitecturesReturn, 
//            GetUpdatedSoftwareWithinReleaseReturn, GetAllUpdatedSoftwareReturn

public interface DownloadService
{

    public abstract GetUpdatedSoftwareWithinReleaseAndArchReturn getUpdatedSoftwareWithinReleaseAndArch(String s, BitVer abitver[], String s1, String s2, String s3)
        throws RemoteException;

    public abstract GetUpdatedSoftwareWithinPasscodeAndArchReturn getUpdatedSoftwareWithinPasscodeAndArch(BitVer abitver[], String s, String s1, String s2)
        throws RemoteException;

    public abstract GetSoftwareProductInfoByLicenseAndArchitecturesReturn getSoftwareProductInfoByLicenseAndArchitectures(String s, String s1, String s2, String as[], String s3, String s4)
        throws RemoteException;

    public abstract String ping(String s)
        throws RemoteException;

    public abstract GetUpdatedSoftwareWithinReleaseReturn getUpdatedSoftwareWithinRelease(BitVer abitver[], String s, String s1)
        throws RemoteException;

    public abstract GetAllUpdatedSoftwareReturn getAllUpdatedSoftware(String s, String s1)
        throws RemoteException;
}
