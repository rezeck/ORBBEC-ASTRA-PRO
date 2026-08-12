#!/usr/bin/env python3
import rospy
from sensor_msgs.msg import Image
import numpy as np


class Brighten:
    def __init__(self):
        self.gain = float(rospy.get_param("~gain", 1.6))
        self.bias = float(rospy.get_param("~bias", 18.0))
        self.pub = rospy.Publisher("/camera/color/image_bright", Image, queue_size=1)
        rospy.Subscriber(
            "/camera/color/image_raw",
            Image,
            self.cb,
            queue_size=1,
            buff_size=2**24,
        )
        rospy.loginfo(
            "color_brighten: publishing /camera/color/image_bright (gain=%.2f bias=%.1f)",
            self.gain,
            self.bias,
        )

    def cb(self, msg):
        ch = 3 if "8" in msg.encoding else 1
        arr = np.frombuffer(msg.data, dtype=np.uint8)
        if ch == 3:
            arr = arr.reshape(msg.height, msg.width, 3).astype(np.float32)
        else:
            arr = arr.reshape(msg.height, msg.width).astype(np.float32)
        out = np.clip(arr * self.gain + self.bias, 0, 255).astype(np.uint8)
        m = Image()
        m.header = msg.header
        m.height = msg.height
        m.width = msg.width
        m.encoding = msg.encoding
        m.is_bigendian = msg.is_bigendian
        m.step = msg.step
        m.data = out.tobytes()
        self.pub.publish(m)


if __name__ == "__main__":
    rospy.init_node("color_brighten")
    Brighten()
    rospy.spin()
