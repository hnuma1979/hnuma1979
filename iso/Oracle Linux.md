# 概要

Oracle Linux は、**Oracle Corporation** が提供する **エンタープライズ向けの Linux ディストリビューション**です。以下にその特徴や用途についてわかりやすく説明します。

---

### 🔹 Oracle Linux の概要

- **ベース**: Red Hat Enterprise Linux（RHEL）互換
- **用途**: サーバー、クラウド、データベース、仮想化環境など
- **ライセンス**: 無償でダウンロード・使用可能（商用サポートは有償）

---

### 🔹 主な特徴

1. **高い互換性**
   - RHEL とバイナリ互換性があり、RHEL 向けのソフトウェアがそのまま動作します。

2. **独自のカーネルオプション**
   - **Unbreakable Enterprise Kernel (UEK)**: Oracle が独自に最適化したカーネル。高性能・高可用性を重視。
   - 標準の RHEL カーネルも選択可能。

3. **無料で利用可能**
   - Oracle Linux 自体は無料でダウンロード・使用可能。
   - 商用サポート（Oracle Premier Support）を契約すれば、企業向けのサポートが受けられます。

4. **クラウド対応**
   - Oracle Cloud Infrastructure（OCI）との親和性が高く、クラウド環境での利用に最適化されています。

5. **セキュリティと安定性**
   - SELinux（Security-Enhanced Linux）対応。
   - Ksplice による**ライブパッチ**（再起動なしでカーネルパッチ適用）が可能（有償）。

---

### 🔹 よく使われる場面

- Oracle Database のホスト OS
- Web サーバーやアプリケーションサーバー
- 仮想化環境（KVM、Oracle VM）
- クラウドインフラ（OCI、AWS、Azure でも利用可能）

---

### 🔹 他の Linux ディストリビューションとの違い

| 特徴 | Oracle Linux | RHEL | CentOS Stream |
|------|--------------|------|----------------|
| 商用サポート | 有り（Oracle） | 有り（Red Hat） | 無し（開発向け） |
| 無償利用 | 可能 | 一部制限あり | 可能 |
| カーネル選択 | UEK / RHEL互換 | RHEL標準 | RHEL標準 |
| ライブパッチ | Ksplice（有償） | 有償オプション | 無し |

---

Anser by Microsoft 365 Copilot

# ダウンロード

* [公式](https://www.oracle.com/linux/downloads/)

## ミラーサイト
* 北陸先端科学技術大学院大学

## dockerhub
* [dockerhub](https://oracle-base.com/articles/linux/articles-linux)

# 関連リンク
* [公式サイト](https://www.oracle.com/linux/)
* [公式ドキュメント](https://docs.oracle.com/en/operating-systems/oracle-linux/)
* [公式GitHub](https://github.com/oracle)

