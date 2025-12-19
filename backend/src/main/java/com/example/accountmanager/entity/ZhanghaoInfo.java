package com.example.accountmanager.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * 账号信息实体类
 * 映射数据库表 zhanghao_info
 */
@Entity
@Table(name = "zhanghao_info")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ZhanghaoInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "userName")
    private String userName;

    @Column(name = "passWord")
    private String passWord;

    @Column(name = "jing_bi")
    private String jingBi;

    @Column(name = "zhuanshi")
    private String zhuanshi;

    @Column(name = "data_time")
    private String dataTime;

    @Column(name = "status")
    private String status;
}
