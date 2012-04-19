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
package com.raytheon.uf.viz.collaboration.comm.identity.listener;

import com.raytheon.uf.viz.collaboration.comm.identity.IPresence;
import com.raytheon.uf.viz.collaboration.comm.provider.user.UserId;

/**
 * TODO Add Description
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Mar 6, 2012            jkorman     Initial creation
 * 
 * </pre>
 * 
 * @author jkorman
 * @version 1.0
 */

public interface IVenueParticipantListener {

    /**
     * A participant has arrived in the venue.
     * 
     * @param participant
     *            The participant who has arrived.
     */
    public void handleArrived(UserId participant);

    /**
     * A participant has has updated their information.
     * 
     * @param participant
     *            The participant whose information has been updated.
     */
    public void handleUpdated(UserId participant);

    /**
     * A participant has departed this venue.
     * 
     * @param participant
     *            The participant who has departed.
     */
    public void handleDeparted(UserId participant);

    /**
     * Presence information about the participant who has arrived, updated, or
     * departed the venue.
     * 
     * @param fromID
     * @param presence
     */
    public void handlePresenceUpdated(UserId fromID, IPresence presence);

}
