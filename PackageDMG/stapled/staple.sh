#!/bin/bash

#
# 公証済パッケージに対してステープラーする
# 
#
#

Xcrun stapler staple *.dmg | tee staple.log
