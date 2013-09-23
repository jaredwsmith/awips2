/**
 * This software was developed and / or modified by Raytheon Company,
 * pursuant to Contract DG133W-05-CQ-1067 with the US Government.
 * 
 * U.S. EXPORT CONTROLLED TECHNICAL DATA
 * This software product contains export-restricted data whose
 * export/transfer/disclosure is restricted by U.S. law. Dissemination
 * to non-U.S. persons whether in the United States or abroad requires
 * an export license or other authorization.
 * 
 * Contractor Name:        Raytheon Company
 * Contractor Address:     6825 Pine Street, Suite 340
 *                         Mail Stop B8
 *                         Omaha, NE 68106
 *                         402.291.0100
 * 
 * See the AWIPS II Master Rights File ("Master Rights File.pdf") for
 * further licensing information.
 **/
package com.raytheon.uf.common.activetable;

import java.util.Calendar;

import com.raytheon.uf.common.serialization.annotations.DynamicSerialize;
import com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement;
import com.raytheon.uf.common.serialization.comm.IServerRequest;

/**
 * TODO Add Description
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Feb 14, 2011            rjpeter     Initial creation
 * Aug 26, 2013  #1843     dgilling    Add performISC field, proper constructors.
 * 
 * </pre>
 * 
 * @author rjpeter
 * @version 1.0
 */
@DynamicSerialize
public class GetNextEtnRequest implements IServerRequest {

    @DynamicSerializeElement
    private String siteID;

    @DynamicSerializeElement
    private ActiveTableMode mode;

    @DynamicSerializeElement
    private String phensig;

    @DynamicSerializeElement
    private Calendar currentTime;

    @DynamicSerializeElement
    private boolean lockEtn;

    @DynamicSerializeElement
    private boolean performISC;

    public GetNextEtnRequest() {
        // no-op, for dynamic serialize support
    }

    /**
     * @param siteID
     * @param mode
     * @param phensig
     * @param currentTime
     * @param lockEtn
     */
    public GetNextEtnRequest(String siteID, ActiveTableMode mode,
            String phensig, Calendar currentTime, boolean lockEtn) {
        this(siteID, mode, phensig, currentTime, lockEtn, false);
    }

    /**
     * @param siteID
     * @param mode
     * @param phensig
     * @param currentTime
     * @param lockEtn
     * @param performISC
     */
    public GetNextEtnRequest(String siteID, ActiveTableMode mode,
            String phensig, Calendar currentTime, boolean lockEtn,
            boolean performISC) {
        this.siteID = siteID;
        this.mode = mode;
        this.phensig = phensig;
        this.currentTime = currentTime;
        this.lockEtn = lockEtn;
        this.performISC = performISC;
    }

    public String getSiteID() {
        return siteID;
    }

    public void setSiteID(String siteID) {
        this.siteID = siteID;
    }

    public ActiveTableMode getMode() {
        return mode;
    }

    public void setMode(ActiveTableMode mode) {
        this.mode = mode;
    }

    public String getPhensig() {
        return phensig;
    }

    public void setPhensig(String phensig) {
        this.phensig = phensig;
    }

    public boolean isLockEtn() {
        return lockEtn;
    }

    public void setLockEtn(boolean lockEtn) {
        this.lockEtn = lockEtn;
    }

    public Calendar getCurrentTime() {
        return currentTime;
    }

    public void setCurrentTime(Calendar currentTime) {
        this.currentTime = currentTime;
    }

    public boolean isPerformISC() {
        return performISC;
    }

    public void setPerformISC(boolean performISC) {
        this.performISC = performISC;
    }
}
