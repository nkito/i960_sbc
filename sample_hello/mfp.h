#ifndef __MFP_H__
#define __MFP_H__


#define MFP_REG_GPDR (*((volatile char *)(0x80000000 + 0x00)))
#define MFP_REG_AER  (*((volatile char *)(0x80000000 + 0x02)))
#define MFP_REG_DDR  (*((volatile char *)(0x80000000 + 0x04)))

#define MFP_REG_IERA (*((volatile char *)(0x80000000 + 0x06)))
#define MFP_REG_IERB (*((volatile char *)(0x80000000 + 0x08)))

#define MFP_REG_IPRA (*((volatile char *)(0x80000000 + 0x0a)))
#define MFP_REG_IPRB (*((volatile char *)(0x80000000 + 0x0c)))

#define MFP_REG_ISRA (*((volatile char *)(0x80000000 + 0x0e)))
#define MFP_REG_ISRB (*((volatile char *)(0x80000000 + 0x10)))

#define MFP_REG_IMRA (*((volatile char *)(0x80000000 + 0x12)))
#define MFP_REG_IMRB (*((volatile char *)(0x80000000 + 0x14)))

#define MFP_REG_VR   (*((volatile char *)(0x80000000 + 0x16)))

#define MFP_REG_TACR (*((volatile char *)(0x80000000 + 0x18)))
#define MFP_REG_TBCR (*((volatile char *)(0x80000000 + 0x1a)))
#define MFP_REG_TCDCR (*((volatile char *)(0x80000000 + 0x1c)))

#define MFP_REG_TADR  (*((volatile char *)(0x80000000 + 0x1e)))
#define MFP_REG_TBDR  (*((volatile char *)(0x80000000 + 0x20)))
#define MFP_REG_TCDR  (*((volatile char *)(0x80000000 + 0x22)))
#define MFP_REG_TDDR  (*((volatile char *)(0x80000000 + 0x24)))

#define MFP_REG_SCR   (*((volatile char *)(0x80000000 + 0x26)))
#define MFP_REG_UCR   (*((volatile char *)(0x80000000 + 0x28)))
#define MFP_REG_RSR   (*((volatile char *)(0x80000000 + 0x2a)))
#define MFP_REG_TSR   (*((volatile char *)(0x80000000 + 0x2c)))
#define MFP_REG_UDR   (*((volatile char *)(0x80000000 + 0x2e)))

#endif
