SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
-- ----------------------------
-- Table structure for su_name
-- ----------------------------
DROP TABLE IF EXISTS `su_name`;
CREATE TABLE `su_name` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;
-- ----------------------------
-- Records of su_name
-- ----------------------------
BEGIN;
INSERT INTO `su_name` (`id`, `name`)
VALUES (1, 'hh');
INSERT INTO `su_name` (`id`, `name`)
VALUES (2, 'joy');
COMMIT;
-- ----------------------------
-- Table structure for su_user
-- ----------------------------
DROP TABLE IF EXISTS `su_user`;
CREATE TABLE `su_user` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'User ID',
  `passport` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'User Passport',
  `password` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'User Password',
  `nickname` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'User Nickname',
  `createTime` bigint NOT NULL DEFAULT '0' COMMENT 'Created Time',
  `updateTime` bigint NOT NULL DEFAULT '0' COMMENT 'Updated Time',
  `telphone` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 4 DEFAULT CHARSET = utf8mb3;
-- ----------------------------
-- Records of su_user
-- ----------------------------
BEGIN;
INSERT INTO `su_user` (
    `id`,
    `passport`,
    `password`,
    `nickname`,
    `createTime`,
    `updateTime`,
    `telphone`
  )
VALUES (
    1,
    '',
    '',
    'biner',
    1620577162252,
    1620577162252,
    '+113888888888'
  );
INSERT INTO `su_user` (
    `id`,
    `passport`,
    `password`,
    `nickname`,
    `createTime`,
    `updateTime`,
    `telphone`
  )
VALUES (
    2,
    '',
    '',
    'biner',
    1620577162252,
    1620577162252,
    '+113888888888'
  );
INSERT INTO `su_user` (
    `id`,
    `passport`,
    `password`,
    `nickname`,
    `createTime`,
    `updateTime`,
    `telphone`
  )
VALUES (
    3,
    '',
    '',
    'biner',
    1620577162252,
    1620577162252,
    '+113888888888'
  );
COMMIT;
SET FOREIGN_KEY_CHECKS = 1;